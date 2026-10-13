# SmartFactory — Bài nộp chung

Gộp SQL, báo cáo đánh đổi, nhật ký AI và bằng chứng thử nghiệm trong một file. Dữ liệu đo là giả lập, không phải hệ thống IoT sản xuất.

## 1. smartfactory_reindex.sql

Chạy một lần trên bảng legacy đã có idx_fat_covering. Kiểm tra index hiện có trước khi chạy.

```sql
USE smartfactory_db;
SET SESSION information_schema_stats_expiry = 0;
ANALYZE TABLE SensorLogs;
SHOW INDEX FROM SensorLogs;
SHOW TABLE STATUS LIKE 'SensorLogs';
SELECT DATA_LENGTH, INDEX_LENGTH,
       ROUND(DATA_LENGTH / 1024 / 1024, 2) AS Data_MiB,
       ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS Index_MiB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'smartfactory_db' AND TABLE_NAME = 'SensorLogs';

EXPLAIN SELECT temperature, humidity, status FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';

ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id, recorded_at);
ANALYZE TABLE SensorLogs;

SHOW INDEX FROM SensorLogs;
SHOW TABLE STATUS LIKE 'SensorLogs';
SELECT DATA_LENGTH, INDEX_LENGTH,
       ROUND(DATA_LENGTH / 1024 / 1024, 2) AS Data_MiB,
       ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS Index_MiB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'smartfactory_db' AND TABLE_NAME = 'SensorLogs';

EXPLAIN SELECT temperature, humidity, status FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';
SELECT temperature, humidity, status FROM SensorLogs
WHERE sensor_id = 105 AND recorded_at >= '2026-06-20';
```

## 2. index_tradeoff_report.md

Thử nghiệm MySQL 8.4.11 dùng 100.000 bản ghi giả lập. Fat index có Index_length 6.832.128 byte (6,52 MiB). Lean index còn 2.637.824 byte (2,52 MiB), giảm 4.194.304 byte, khoảng 61,39%. Data_length không đổi: 5.783.552 byte. EXPLAIN trước và sau đều range, ước lượng 53 dòng; key đổi từ idx_fat_covering sang idx_lean_search. Extra đổi từ “Using where; Using index” sang “Using index condition”. Số dòng và tổng nhiệt độ, độ ẩm đối chiếu đều khớp.

Index mới giữ sensor_id và recorded_at để lọc. Nó không bao phủ temperature, humidity, status nên cần đọc dòng trong clustered index. Đổi lại, bản ghi index nhỏ hơn, giảm dung lượng, áp lực cache và lượng dữ liệu phải bảo trì khi ghi. INSERT có thể nhanh hơn, nhưng chưa đo benchmark nên không khẳng định tăng năm lần hoặc SELECT chỉ chậm một phần nghìn giây.

Covering index vẫn hợp lý cho bảng Countries ít ghi và thường xuyên đọc. Write penalty gồm bảo trì page, log và khả năng chia page, không phải sắp xếp lại toàn bộ cây mỗi lần INSERT. Index_length giảm cũng chưa chứng minh file .ibd trả dung lượng về hệ điều hành.

| Chỉ số thực đo | Fat index | Lean index |
|---|---|---|
| Index_length (byte) | 6832128 | 2637824 |
| Data_length (byte) | 5783552 | 5783552 |
| type | range | range |
| key | idx_fat_covering | idx_lean_search |
| rows ước lượng | 53 | 53 |
| Extra | Using where; Using index | Using index condition |

## 3. ai_prompt_log.md

### Trao đổi thực tế

Người dùng gửi toàn bộ đề SmartFactory qua file đính kèm trong ngữ cảnh yêu cầu làm bài chung một file và đẩy GitHub. AI đọc đề, tạo bản nháp, chạy thử và báo kết quả. Không có các câu hỏi kỹ thuật riêng do người dùng đặt; các prompt gợi ý không được ghi thành lịch sử hỏi đáp giả.

AI đã thông báo kết quả thực tế: index giảm 6,52 xuống 2,52 MiB, truy vấn vẫn range và idx_lean_search; không dùng các con số tăng năm lần hoặc giảm 70% của đề khi chưa đo.

### Tra cứu kỹ thuật đã thực hiện

AI tra tài liệu MySQL chính thức về dung lượng kiểu dữ liệu: [Data Type Storage Requirements](https://dev.mysql.com/doc/refman/8.4/en/storage-requirements.html).

- INT: 4 byte; BIGINT: 8 byte; DATETIME không có phần giây lẻ: 5 byte; DECIMAL(5,2): 3 byte (2 cho phần nguyên, 1 cho phần thập phân).
- Lean index có phần giá trị sensor_id + recorded_at là 9 byte, cộng khóa chính BIGINT 8 byte trong secondary index, chưa tính overhead record/page.
- Fat index thêm hai DECIMAL tổng 6 byte và status. Với chuỗi ASCII NORMAL/WARNING/CRITICAL, phần VARCHAR cần khoảng 7/8/9 byte gồm độ dài. Tiết kiệm payload lý thuyết khoảng 13–15 byte mỗi entry, chưa tính overhead và cách phân bổ page. Không dùng phép tính này thay cho Index_length thực đo.
- Đổi status sang TINYINT cần ánh xạ và ràng buộc nghiệp vụ; phần giá trị chỉ 1 byte. Có thể giảm cả dòng dữ liệu và fat index nếu status nằm trong index. Lean index không chứa status nên không giảm trực tiếp payload của lean index.
- InnoDB clustered index lưu dòng; secondary index chứa khóa chính để tìm dòng. Covering index tránh lookup dòng nhưng vẫn có thể đọc index page từ ổ đĩa nếu chưa có trong buffer pool.
- Truy vấn giữ kết quả sau thay index, nhưng tốc độ đọc có thể khác. Không có benchmark INSERT, RAM, IOPS hoặc hóa đơn cloud để quy toàn bộ sự cố cho index.

### Phạm vi AI và kiểm chứng

Đề giới hạn AI ở giải thích, không viết toàn bộ đáp án. Bản nháp này do AI tạo rộng hơn phạm vi đó; học viên cần tự kiểm tra, thực hành và trao đổi với giảng viên trước khi nộp. Thử nghiệm thực tế dùng MySQL 8.4.11 trên server riêng, 100.000 dòng và 1.000 sensor_id giả lập. Không tuyên bố đã sửa dữ liệu sản xuất, đo tiết kiệm RAM hoặc chứng minh tăng tốc ghi.

## 4. Script tái lập và log thực tế

Script dưới đây chỉ chạy trên server thử chưa có smartfactory_db. Log giữ nguyên kết quả MySQL để đối chiếu.

```sql
CREATE DATABASE smartfactory_db;
USE smartfactory_db;
CREATE TABLE SensorLogs (
 log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 sensor_id INT NOT NULL,
 recorded_at DATETIME NOT NULL,
 temperature DECIMAL(5,2), humidity DECIMAL(5,2), status VARCHAR(20)
) ENGINE=InnoDB;
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id,recorded_at,temperature,humidity,status);
CREATE TABLE digits(n INT PRIMARY KEY);
INSERT INTO digits VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
INSERT INTO SensorLogs(sensor_id,recorded_at,temperature,humidity,status)
SELECT MOD(n,1000)+1, DATE_ADD('2026-01-01',INTERVAL MOD(n,365) DAY),
20+MOD(n,2000)/100,40+MOD(n,5000)/100,
ELT(MOD(n,3)+1,'NORMAL','WARNING','CRITICAL')
FROM (SELECT a.n+10*b.n+100*c.n+1000*d.n+10000*e.n AS n
FROM digits a CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits d CROSS JOIN digits e) s;
SET SESSION information_schema_stats_expiry=0;
ANALYZE TABLE SensorLogs;
SELECT VERSION() AS version,COUNT(*) AS sample_rows FROM SensorLogs;
SELECT 'BEFORE' AS phase,DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='smartfactory_db' AND TABLE_NAME='SensorLogs';
EXPLAIN SELECT temperature,humidity,status FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
SELECT COUNT(*),SUM(temperature),SUM(humidity) INTO @old_count,@old_temp,@old_hum
FROM SensorLogs WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering;
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id,recorded_at);
ANALYZE TABLE SensorLogs;
SELECT 'AFTER' AS phase,DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='smartfactory_db' AND TABLE_NAME='SensorLogs';
EXPLAIN SELECT temperature,humidity,status FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
SELECT COUNT(*) AS matched_rows, COUNT(*)=@old_count AS count_matches,
SUM(temperature)<=>@old_temp AS temperature_sum_matches,
SUM(humidity)<=>@old_hum AS humidity_sum_matches
FROM SensorLogs WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
SHOW INDEX FROM SensorLogs;

```

### Log console

```text
--------------
CREATE DATABASE smartfactory_db
--------------

--------------
CREATE TABLE SensorLogs (
 log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
 sensor_id INT NOT NULL,
 recorded_at DATETIME NOT NULL,
 temperature DECIMAL(5,2), humidity DECIMAL(5,2), status VARCHAR(20)
) ENGINE=InnoDB
--------------

--------------
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id,recorded_at,temperature,humidity,status)
--------------

--------------
CREATE TABLE digits(n INT PRIMARY KEY)
--------------

--------------
INSERT INTO digits VALUES(0),(1),(2),(3),(4),(5),(6),(7),(8),(9)
--------------

--------------
INSERT INTO SensorLogs(sensor_id,recorded_at,temperature,humidity,status)
SELECT MOD(n,1000)+1, DATE_ADD('2026-01-01',INTERVAL MOD(n,365) DAY),
20+MOD(n,2000)/100,40+MOD(n,5000)/100,
ELT(MOD(n,3)+1,'NORMAL','WARNING','CRITICAL')
FROM (SELECT a.n+10*b.n+100*c.n+1000*d.n+10000*e.n AS n
FROM digits a CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits d CROSS JOIN digits e) s
--------------

--------------
SET SESSION information_schema_stats_expiry=0
--------------

--------------
ANALYZE TABLE SensorLogs
--------------

+----------------------------+---------+----------+----------+
| Table                      | Op      | Msg_type | Msg_text |
+----------------------------+---------+----------+----------+
| smartfactory_db.sensorlogs | analyze | status   | OK       |
+----------------------------+---------+----------+----------+
--------------
SELECT VERSION() AS version,COUNT(*) AS sample_rows FROM SensorLogs
--------------

+---------+-------------+
| version | sample_rows |
+---------+-------------+
| 8.4.11  |      100000 |
+---------+-------------+
--------------
SELECT 'BEFORE' AS phase,DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='smartfactory_db' AND TABLE_NAME='SensorLogs'
--------------

+--------+-------------+--------------+----------+-----------+
| phase  | DATA_LENGTH | INDEX_LENGTH | data_mib | index_mib |
+--------+-------------+--------------+----------+-----------+
| BEFORE |     5783552 |      6832128 |     5.52 |      6.52 |
+--------+-------------+--------------+----------+-----------+
--------------
EXPLAIN SELECT temperature,humidity,status FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20'
--------------

+----+-------------+------------+------------+-------+------------------+------------------+---------+------+------+----------+--------------------------+
| id | select_type | table      | partitions | type  | possible_keys    | key              | key_len | ref  | rows | filtered | Extra                    |
+----+-------------+------------+------------+-------+------------------+------------------+---------+------+------+----------+--------------------------+
|  1 | SIMPLE      | SensorLogs | NULL       | range | idx_fat_covering | idx_fat_covering | 9       | NULL |   53 |   100.00 | Using where; Using index |
+----+-------------+------------+------------+-------+------------------+------------------+---------+------+------+----------+--------------------------+
--------------
SELECT COUNT(*),SUM(temperature),SUM(humidity) INTO @old_count,@old_temp,@old_hum
FROM SensorLogs WHERE sensor_id=105 AND recorded_at >= '2026-06-20'
--------------

--------------
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering
--------------

--------------
CREATE INDEX idx_lean_search ON SensorLogs(sensor_id,recorded_at)
--------------

--------------
ANALYZE TABLE SensorLogs
--------------

+----------------------------+---------+----------+----------+
| Table                      | Op      | Msg_type | Msg_text |
+----------------------------+---------+----------+----------+
| smartfactory_db.sensorlogs | analyze | status   | OK       |
+----------------------------+---------+----------+----------+
--------------
SELECT 'AFTER' AS phase,DATA_LENGTH,INDEX_LENGTH,
ROUND(DATA_LENGTH/1024/1024,2) AS data_mib,ROUND(INDEX_LENGTH/1024/1024,2) AS index_mib
FROM information_schema.TABLES WHERE TABLE_SCHEMA='smartfactory_db' AND TABLE_NAME='SensorLogs'
--------------

+-------+-------------+--------------+----------+-----------+
| phase | DATA_LENGTH | INDEX_LENGTH | data_mib | index_mib |
+-------+-------------+--------------+----------+-----------+
| AFTER |     5783552 |      2637824 |     5.52 |      2.52 |
+-------+-------------+--------------+----------+-----------+
--------------
EXPLAIN SELECT temperature,humidity,status FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20'
--------------

+----+-------------+------------+------------+-------+-----------------+-----------------+---------+------+------+----------+-----------------------+
| id | select_type | table      | partitions | type  | possible_keys   | key             | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+------------+------------+-------+-----------------+-----------------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | SensorLogs | NULL       | range | idx_lean_search | idx_lean_search | 9       | NULL |   53 |   100.00 | Using index condition |
+----+-------------+------------+------------+-------+-----------------+-----------------+---------+------+------+----------+-----------------------+
--------------
SELECT COUNT(*) AS matched_rows, COUNT(*)=@old_count AS count_matches,
SUM(temperature)<=>@old_temp AS temperature_sum_matches,
SUM(humidity)<=>@old_hum AS humidity_sum_matches
FROM SensorLogs WHERE sensor_id=105 AND recorded_at >= '2026-06-20'
--------------

+--------------+---------------+-------------------------+----------------------+
| matched_rows | count_matches | temperature_sum_matches | humidity_sum_matches |
+--------------+---------------+-------------------------+----------------------+
|           53 |             1 |                       1 |                    1 |
+--------------+---------------+-------------------------+----------------------+
--------------
SHOW INDEX FROM SensorLogs
--------------

+------------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table      | Non_unique | Key_name        | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+------------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| sensorlogs |          0 | PRIMARY         |            1 | log_id      | A         |       99900 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| sensorlogs |          1 | idx_lean_search |            1 | sensor_id   | A         |        1000 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| sensorlogs |          1 | idx_lean_search |            2 | recorded_at | A         |       73134 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+------------+------------+-----------------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+

```