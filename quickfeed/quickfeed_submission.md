# QuickFeed — Bài nộp chung

File này gộp SQL, báo cáo dung lượng, nhật ký AI và log thực nghiệm. Không có dữ liệu người dùng thật.

## 1. quickfeed_index_optimization.sql

Chạy trên bảng legacy đã có 5 index theo đề. Các lệnh DROP chỉ chạy một lần. Kiểm tra SHOW INDEX trước khi chạy trên môi trường của bạn.

```sql
USE quickfeed_db;
SET SESSION information_schema_stats_expiry = 0;
ANALYZE TABLE Posts;

-- Ghi nhận trước tối ưu.
SHOW INDEX FROM Posts;
SHOW TABLE STATUS LIKE 'Posts';
SELECT TABLE_NAME, DATA_LENGTH, INDEX_LENGTH,
       ROUND(DATA_LENGTH / 1024 / 1024, 2) AS Data_MiB,
       ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS Index_MiB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'quickfeed_db' AND TABLE_NAME = 'Posts';

-- Chỉ bỏ 3 index đã phân tích, giữ PRIMARY và 2 index hữu ích.
ALTER TABLE Posts
    DROP INDEX idx_content,
    DROP INDEX idx_post_type,
    DROP INDEX idx_is_visible;

ANALYZE TABLE Posts;
SHOW INDEX FROM Posts;
SHOW TABLE STATUS LIKE 'Posts';
SELECT TABLE_NAME, DATA_LENGTH, INDEX_LENGTH,
       ROUND(DATA_LENGTH / 1024 / 1024, 2) AS Data_MiB,
       ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS Index_MiB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'quickfeed_db' AND TABLE_NAME = 'Posts';
```

| Index | Quyết định | Lý do theo workload của đề |
|---|---|---|
| PRIMARY | Giữ | Khóa định danh, clustered index của InnoDB |
| idx_user_id | Giữ | Truy xuất bài theo người dùng |
| idx_content | Xóa | Prefix dài, chưa có truy vấn prefix cần index này |
| idx_post_type | Xóa | Chỉ 3 giá trị, chưa có truy vấn chọn lọc đủ để bù chi phí ghi |
| idx_is_visible | Xóa | 99% bài visible trong mẫu, lọc visible=1 ít chọn lọc |
| idx_created_at | Giữ | Phục vụ thứ tự thời gian và truy vấn khoảng ngày |

## 2. storage_performance_report.md

Thử nghiệm dùng MySQL 8.4.11, InnoDB và 100.000 bài viết giả lập trên server riêng. Trước tối ưu, Data_length là 32.047.104 byte (30,56 MiB), Index_length là 59.834.368 byte (57,06 MiB). Sau khi bỏ ba index, dữ liệu giữ nguyên, Index_length còn 9.469.952 byte (9,03 MiB), giảm 50.364.416 byte, khoảng 84,17%. Số bài vẫn là 100.000; PRIMARY, idx_user_id và idx_created_at còn tồn tại.

INSERT phải ghi dòng vào clustered index và duy trì năm secondary index. Bỏ ba index loại bỏ ba cấu trúc cần bảo trì cho mỗi dòng mới, giảm áp lực page, buffer pool và log. Điều này không có nghĩa thao tác ghi nhanh gấp ba; chưa đo benchmark INSERT nên chưa kết luận hệ số tăng tốc.

Đánh đổi là truy vấn từng dùng index bị bỏ có thể chậm hơn. Cột ít giá trị không luôn vô ích: giá trị hiếm vẫn có thể chọn lọc tốt. Bảng archive ít ghi có thể chấp nhận thêm index phục vụ đọc. FULLTEXT phù hợp tìm từ khóa, nhưng cũng tốn dung lượng. Index_length giảm không chứng minh file .ibd đã co lại hoặc dung lượng được trả ngay về hệ điều hành; cần đo riêng khi nghiệm thu.

## 3. ai_prompt_log.md

### Lịch sử thực tế

Người dùng gửi file đề QuickFeed trong cuộc hội thoại đã yêu cầu gộp mỗi bài thành một file và đẩy GitHub. AI đọc đề, giải thích kế hoạch bỏ đúng ba index, tạo dữ liệu giả lập, chạy MySQL và tổng hợp kết quả. Không có các câu hỏi độc lập về Cardinality hoặc Storage do người dùng đặt; không ghi các prompt gợi ý trong đề như lịch sử đã diễn ra.

Phản hồi AI thực tế trong phiên:

> Tôi sẽ thử trên dữ liệu giả lập để đo dung lượng index trước/sau, chỉ xoá idx_content, idx_post_type, idx_is_visible và giữ hai index còn lại.

Sau khi chạy, AI giải thích số liệu Index_length giảm khác với bằng chứng hệ điều hành đã thu hồi dung lượng. Đây là các trao đổi thực tế, không phải nhật ký hỏi đáp kỹ thuật được tạo ngược để lấy điểm.

### Nội dung kỹ thuật đã phân tích

- Cardinality là số lượng giá trị phân biệt; selectivity còn phụ thuộc tỷ lệ dòng khớp điều kiện. Không kết luận mọi index BOOLEAN đều vô nghĩa.
- InnoDB lưu dòng trong clustered index theo PRIMARY KEY; secondary index có khóa index và khóa chính để tìm dòng. Prefix content(255) có thể lớn và không hỗ trợ tìm chuỗi tùy ý bằng LIKE '%keyword%'.
- Truy vấn is_visible=1 khớp phần lớn dữ liệu có thể làm table scan rẻ hơn lookup và đọc dòng qua index.
- Khi INSERT, bảo trì index có thể phát sinh sửa page, chia page và log; không phải chính xác một lần ghi đĩa cho mỗi index. Timeout cần thêm bằng chứng tải thực tế.
- FULLTEXT hỗ trợ tìm kiếm từ; không mặc định ít dung lượng hơn mọi prefix index.
- information_schema.TABLES cho thống kê lưu trữ, không phải phép đo trực tiếp số byte ổ đĩa được thu hồi.

### Giới hạn sử dụng AI

Đề giới hạn AI ở giải thích và hỗ trợ tra cứu. Bản nháp này do AI triển khai rộng hơn phạm vi đó; học viên cần tự kiểm tra và trao đổi với giảng viên trước khi nộp. Không tuyên bố đây là bài tự làm hoặc dữ liệu sản xuất đã được sửa.

## 4. Bằng chứng và cách tái lập

Đã chạy thành công trên server thử riêng. Dữ liệu sinh từ tích Descartes 5 bảng chữ số 0–9, tạo 100.000 dòng, 10.000 user_id, 3 post_type, 99% is_visible=1. Nội dung gồm MD5 của số thứ tự và đoạn văn lặp; created_at tăng theo giây. Log console nguyên bản được gộp bên dưới. MiB = 1024 × 1024 byte.

### Script tái lập trên server thử trống

```sql
CREATE DATABASE quickfeed_db;
USE quickfeed_db;
CREATE TABLE Posts (
 post_id INT AUTO_INCREMENT PRIMARY KEY,
 user_id INT NOT NULL,
 content TEXT,
 post_type VARCHAR(10),
 is_visible BOOLEAN DEFAULT 1,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE INDEX idx_user_id ON Posts(user_id);
CREATE INDEX idx_content ON Posts(content(255));
CREATE INDEX idx_post_type ON Posts(post_type);
CREATE INDEX idx_is_visible ON Posts(is_visible);
CREATE INDEX idx_created_at ON Posts(created_at);
CREATE TABLE digits(n INT PRIMARY KEY);
INSERT INTO digits VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
INSERT INTO Posts(user_id,content,post_type,is_visible,created_at)
SELECT MOD(n,10000)+1,CONCAT(MD5(n),REPEAT(' QuickFeed demo content.',9)),
ELT(MOD(n,3)+1,'TEXT','IMAGE','VIDEO'), IF(MOD(n,100)=0,0,1),
DATE_ADD('2026-01-01', INTERVAL n SECOND)
FROM (SELECT a.n+10*b.n+100*c.n+1000*d.n+10000*e.n AS n
FROM digits a CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits d CROSS JOIN digits e) s;
SET SESSION information_schema_stats_expiry=0;
ANALYZE TABLE Posts;
SELECT VERSION() AS version, COUNT(*) AS sample_rows FROM Posts;
SELECT 'BEFORE' AS phase, DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='quickfeed_db' AND TABLE_NAME='Posts';
SHOW INDEX FROM Posts;
ALTER TABLE Posts DROP INDEX idx_content, DROP INDEX idx_post_type, DROP INDEX idx_is_visible;
ANALYZE TABLE Posts;
SELECT 'AFTER' AS phase, DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='quickfeed_db' AND TABLE_NAME='Posts';
SHOW INDEX FROM Posts;
SELECT COUNT(*) AS rows_after FROM Posts;

```

### Log console thực tế

```text
--------------
CREATE DATABASE quickfeed_db
--------------

--------------
CREATE TABLE Posts (
 post_id INT AUTO_INCREMENT PRIMARY KEY,
 user_id INT NOT NULL,
 content TEXT,
 post_type VARCHAR(10),
 is_visible BOOLEAN DEFAULT 1,
 created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB
--------------

--------------
CREATE INDEX idx_user_id ON Posts(user_id)
--------------

--------------
CREATE INDEX idx_content ON Posts(content(255))
--------------

--------------
CREATE INDEX idx_post_type ON Posts(post_type)
--------------

--------------
CREATE INDEX idx_is_visible ON Posts(is_visible)
--------------

--------------
CREATE INDEX idx_created_at ON Posts(created_at)
--------------

--------------
CREATE TABLE digits(n INT PRIMARY KEY)
--------------

--------------
INSERT INTO digits VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)
--------------

--------------
INSERT INTO Posts(user_id,content,post_type,is_visible,created_at)
SELECT MOD(n,10000)+1,CONCAT(MD5(n),REPEAT(' QuickFeed demo content.',9)),
ELT(MOD(n,3)+1,'TEXT','IMAGE','VIDEO'), IF(MOD(n,100)=0,0,1),
DATE_ADD('2026-01-01', INTERVAL n SECOND)
FROM (SELECT a.n+10*b.n+100*c.n+1000*d.n+10000*e.n AS n
FROM digits a CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits d CROSS JOIN digits e) s
--------------

--------------
SET SESSION information_schema_stats_expiry=0
--------------

--------------
ANALYZE TABLE Posts
--------------

+--------------------+---------+----------+----------+
| Table              | Op      | Msg_type | Msg_text |
+--------------------+---------+----------+----------+
| quickfeed_db.posts | analyze | status   | OK       |
+--------------------+---------+----------+----------+
--------------
SELECT VERSION() AS version, COUNT(*) AS sample_rows FROM Posts
--------------

+---------+-------------+
| version | sample_rows |
+---------+-------------+
| 8.4.11  |      100000 |
+---------+-------------+
--------------
SELECT 'BEFORE' AS phase, DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='quickfeed_db' AND TABLE_NAME='Posts'
--------------

+--------+-------------+--------------+----------+-----------+
| phase  | DATA_LENGTH | INDEX_LENGTH | data_mib | index_mib |
+--------+-------------+--------------+----------+-----------+
| BEFORE |    32047104 |     59834368 |    30.56 |     57.06 |
+--------+-------------+--------------+----------+-----------+
--------------
SHOW INDEX FROM Posts
--------------

+-------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name       | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| posts |          0 | PRIMARY        |            1 | post_id     | A         |       98124 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_user_id    |            1 | user_id     | A         |        9616 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_content    |            1 | content     | A         |       98124 |      255 |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_post_type  |            1 | post_type   | A         |           2 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_is_visible |            1 | is_visible  | A         |           1 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_created_at |            1 | created_at  | A         |       98124 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
--------------
ALTER TABLE Posts DROP INDEX idx_content, DROP INDEX idx_post_type, DROP INDEX idx_is_visible
--------------

--------------
ANALYZE TABLE Posts
--------------

+--------------------+---------+----------+----------+
| Table              | Op      | Msg_type | Msg_text |
+--------------------+---------+----------+----------+
| quickfeed_db.posts | analyze | status   | OK       |
+--------------------+---------+----------+----------+
--------------
SELECT 'AFTER' AS phase, DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='quickfeed_db' AND TABLE_NAME='Posts'
--------------

+-------+-------------+--------------+----------+-----------+
| phase | DATA_LENGTH | INDEX_LENGTH | data_mib | index_mib |
+-------+-------------+--------------+----------+-----------+
| AFTER |    32047104 |      9469952 |    30.56 |      9.03 |
+-------+-------------+--------------+----------+-----------+
--------------
SHOW INDEX FROM Posts
--------------

+-------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table | Non_unique | Key_name       | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| posts |          0 | PRIMARY        |            1 | post_id     | A         |       98124 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_user_id    |            1 | user_id     | A         |       10467 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| posts |          1 | idx_created_at |            1 | created_at  | A         |       79570 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-------+------------+----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
--------------
SELECT COUNT(*) AS rows_after FROM Posts
--------------

+------------+
| rows_after |
+------------+
|     100000 |
+------------+

```