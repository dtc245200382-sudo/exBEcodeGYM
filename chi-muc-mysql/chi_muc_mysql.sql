-- [Thực hành] Chỉ mục trong MySQL
-- Một file chung: câu lệnh thực hành và kết quả thử nghiệm ở cuối file.
-- Import classicmodels trước từ nguồn trong đề:
-- https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/
-- Chạy trên bản mẫu chưa có idx_customerName và idx_full_name.
USE `classicmodels`;

SELECT VERSION() AS `MySQLVersion`, COUNT(*) AS `SoKhachHang` FROM `customers`;
SHOW INDEX FROM `customers`;

-- 1. Truy vấn và kế hoạch trước khi tạo chỉ mục tên khách hàng.
SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.';
EXPLAIN SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.';
EXPLAIN ANALYZE SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.';

-- 2. Tạo chỉ mục đơn và so sánh kế hoạch/thời gian thực thi.
ALTER TABLE `customers` ADD INDEX `idx_customerName` (`customerName`);
ANALYZE TABLE `customers`;
EXPLAIN SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.';
EXPLAIN ANALYZE SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.';

-- 3. Khảo sát truy vấn tên người liên hệ trước chỉ mục ghép.
EXPLAIN SELECT * FROM `customers`
WHERE `contactFirstName` = 'Jean' OR `contactFirstName` = 'King';

-- 4. Tạo chỉ mục ghép và kiểm tra truy vấn theo cột đầu của index.
ALTER TABLE `customers` ADD INDEX `idx_full_name` (`contactFirstName`, `contactLastName`);
ANALYZE TABLE `customers`;
EXPLAIN SELECT * FROM `customers`
WHERE `contactFirstName` = 'Jean' OR `contactFirstName` = 'King';
SELECT * FROM `customers`
WHERE `contactFirstName` = 'Jean' OR `contactFirstName` = 'King';

-- 5. Xóa chỉ mục ghép theo yêu cầu và kiểm tra lại.
ALTER TABLE `customers` DROP INDEX `idx_full_name`;
SHOW INDEX FROM `customers`;

-- Ghi chú đọc EXPLAIN:
-- possible_keys: chỉ mục có thể dùng; key: chỉ mục được chọn.
-- rows: số dòng ước lượng, không phải số dòng thực đo.
-- ref: tra cứu khóa không duy nhất, không bảo đảm chỉ một kết quả.
-- Index ghép có thể dùng tiền tố trái contactFirstName trong ví dụ trên.
-- EXPLAIN ANALYZE chạy truy vấn thực tế, cần MySQL 8.0.18 trở lên.
-- Không mặc định Using filesort/Using temporary luôn là lỗi hiệu năng.
-- Index làm tăng dung lượng và chi phí INSERT/UPDATE/DELETE.

-- KẾT QUẢ THỬ NGHIỆM THỰC TẾ
-- MySQL 8.4.11, classicmodels tải từ nguồn đề bài, 122 khách hàng.
-- Tên khách hàng: ALL / rows 122 / key NULL -> ref / rows 1 / idx_customerName.
-- EXPLAIN ANALYZE: truy vấn trước index kết thúc khoảng 0.240 ms; sau index 0.0173 ms.
-- Đây là một lần đo trên dữ liệu nhỏ, không phải benchmark sản xuất.
-- Tên liên hệ: ALL / rows 122 -> range / rows 2 / idx_full_name.
-- idx_full_name đã được xóa; idx_customerName được giữ lại.
-- key_len thực tế 202, không phải 52 như ảnh minh họa; phụ thuộc cấu trúc và charset.
-- Log console nguyên bản bên dưới được đặt trong comment để file vẫn chạy được.

/* LOG CONSOLE THỰC TẾ
--------------
-- [Th?c h?nh] Ch? m?c trong MySQL
--------------

--------------
-- M?t file chung: c?u l?nh th?c h?nh v? k?t qu? th? nghi?m ? cu?i file.
--------------

--------------
-- Import classicmodels tr??c t? ngu?n trong ??:
--------------

--------------
-- https://www.mysqltutorial.org/getting-started-with-mysql/mysql-sample-database/
--------------

--------------
-- Ch?y tr?n b?n m?u ch?a c? idx_customerName v? idx_full_name.
--------------

--------------
SELECT VERSION() AS `MySQLVersion`, COUNT(*) AS `SoKhachHang` FROM `customers`
--------------

+--------------+-------------+
| MySQLVersion | SoKhachHang |
+--------------+-------------+
| 8.4.11       |         122 |
+--------------+-------------+
--------------
SHOW INDEX FROM `customers`
--------------

+-----------+------------+------------------------+--------------+------------------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name               | Seq_in_index | Column_name            | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+------------------------+--------------+------------------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | PRIMARY                |            1 | customerNumber         | A         |         122 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| customers |          1 | salesRepEmployeeNumber |            1 | salesRepEmployeeNumber | A         |          16 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
+-----------+------------+------------------------+--------------+------------------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
--------------
-- 1. Truy v?n v? k? ho?ch tr??c khi t?o ch? m?c t?n kh?ch h?ng.
--------------

--------------
SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.'
--------------

+----------------+-------------------+-----------------+------------------+------------+-------------------------+--------------+------+-------+------------+---------+------------------------+-------------+
| customerNumber | customerName      | contactLastName | contactFirstName | phone      | addressLine1            | addressLine2 | city | state | postalCode | country | salesRepEmployeeNumber | creditLimit |
+----------------+-------------------+-----------------+------------------+------------+-------------------------+--------------+------+-------+------------+---------+------------------------+-------------+
|            131 | Land of Toys Inc. | Lee             | Kwai             | 2125557818 | 897 Long Airport Avenue | NULL         | NYC  | NY    | 10022      | USA     |                   1323 |   114900.00 |
+----------------+-------------------+-----------------+------------------+------------+-------------------------+--------------+------+-------+------------+---------+------------------------+-------------+
--------------
EXPLAIN SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.'
--------------

+----+-------------+-----------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table     | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-----------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | customers | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  122 |    10.00 | Using where |
+----+-------------+-----------+------------+------+---------------+------+---------+------+------+----------+-------------+
--------------
EXPLAIN ANALYZE SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.'
--------------

+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| -> Filter: (customers.customerName = 'Land of Toys Inc.')  (cost=12.4 rows=12.2) (actual time=0.177..0.24 rows=1 loops=1)
    -> Table scan on customers  (cost=12.4 rows=122) (actual time=0.171..0.23 rows=122 loops=1)
 |
+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
--------------
-- 2. T?o ch? m?c ??n v? so s?nh k? ho?ch/th?i gian th?c thi.
--------------

--------------
ALTER TABLE `customers` ADD INDEX `idx_customerName` (`customerName`)
--------------

--------------
ANALYZE TABLE `customers`
--------------

+-------------------------+---------+----------+----------+
| Table                   | Op      | Msg_type | Msg_text |
+-------------------------+---------+----------+----------+
| classicmodels.customers | analyze | status   | OK       |
+-------------------------+---------+----------+----------+
--------------
EXPLAIN SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.'
--------------

+----+-------------+-----------+------------+------+------------------+------------------+---------+-------+------+----------+-------+
| id | select_type | table     | partitions | type | possible_keys    | key              | key_len | ref   | rows | filtered | Extra |
+----+-------------+-----------+------------+------+------------------+------------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | customers | NULL       | ref  | idx_customerName | idx_customerName | 202     | const |    1 |   100.00 | NULL  |
+----+-------------+-----------+------------+------+------------------+------------------+---------+-------+------+----------+-------+
--------------
EXPLAIN ANALYZE SELECT * FROM `customers` WHERE `customerName` = 'Land of Toys Inc.'
--------------

+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| EXPLAIN                                                                                                                                                 |
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
| -> Index lookup on customers using idx_customerName (customerName='Land of Toys Inc.')  (cost=0.35 rows=1) (actual time=0.0162..0.0173 rows=1 loops=1)
 |
+---------------------------------------------------------------------------------------------------------------------------------------------------------+
--------------
-- 3. Kh?o s?t truy v?n t?n ng??i li?n h? tr??c ch? m?c gh?p.
--------------

--------------
EXPLAIN SELECT * FROM `customers`
WHERE `contactFirstName` = 'Jean' OR `contactFirstName` = 'King'
--------------

+----+-------------+-----------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table     | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+-----------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | customers | NULL       | ALL  | NULL          | NULL | NULL    | NULL |  122 |    19.00 | Using where |
+----+-------------+-----------+------------+------+---------------+------+---------+------+------+----------+-------------+
--------------
-- 4. T?o ch? m?c gh?p v? ki?m tra truy v?n theo c?t ??u c?a index.
--------------

--------------
ALTER TABLE `customers` ADD INDEX `idx_full_name` (`contactFirstName`, `contactLastName`)
--------------

--------------
ANALYZE TABLE `customers`
--------------

+-------------------------+---------+----------+----------+
| Table                   | Op      | Msg_type | Msg_text |
+-------------------------+---------+----------+----------+
| classicmodels.customers | analyze | status   | OK       |
+-------------------------+---------+----------+----------+
--------------
EXPLAIN SELECT * FROM `customers`
WHERE `contactFirstName` = 'Jean' OR `contactFirstName` = 'King'
--------------

+----+-------------+-----------+------------+-------+---------------+---------------+---------+------+------+----------+-----------------------+
| id | select_type | table     | partitions | type  | possible_keys | key           | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+-----------+------------+-------+---------------+---------------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | customers | NULL       | range | idx_full_name | idx_full_name | 202     | NULL |    2 |   100.00 | Using index condition |
+----+-------------+-----------+------------+-------+---------------+---------------+---------+------+------+----------+-----------------------+
--------------
SELECT * FROM `customers`
WHERE `contactFirstName` = 'Jean' OR `contactFirstName` = 'King'
--------------

+----------------+--------------------+-----------------+------------------+------------+-----------------+--------------+-----------+-------+------------+---------+------------------------+-------------+
| customerNumber | customerName       | contactLastName | contactFirstName | phone      | addressLine1    | addressLine2 | city      | state | postalCode | country | salesRepEmployeeNumber | creditLimit |
+----------------+--------------------+-----------------+------------------+------------+-----------------+--------------+-----------+-------+------------+---------+------------------------+-------------+
|            112 | Signal Gift Stores | King            | Jean             | 7025551838 | 8489 Strong St. | NULL         | Las Vegas | NV    | 83030      | USA     |                   1166 |    71800.00 |
+----------------+--------------------+-----------------+------------------+------------+-----------------+--------------+-----------+-------+------------+---------+------------------------+-------------+
--------------
-- 5. X?a ch? m?c gh?p theo y?u c?u v? ki?m tra l?i.
--------------

--------------
ALTER TABLE `customers` DROP INDEX `idx_full_name`
--------------

--------------
SHOW INDEX FROM `customers`
--------------

+-----------+------------+------------------------+--------------+------------------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table     | Non_unique | Key_name               | Seq_in_index | Column_name            | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+-----------+------------+------------------------+--------------+------------------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| customers |          0 | PRIMARY                |            1 | customerNumber         | A         |         122 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| customers |          1 | salesRepEmployeeNumber |            1 | salesRepEmployeeNumber | A         |          16 |     NULL |   NULL | YES  | BTREE      |         |               | YES     | NULL       |
| customers |          1 | idx_customerName       |            1 | customerName           | A         |         122 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+-----------+------------+------------------------+--------------+------------------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
--------------
-- Ghi ch? ??c EXPLAIN:
--------------

--------------
-- possible_keys: ch? m?c c? th? d?ng; key: ch? m?c ???c ch?n.
--------------

--------------
-- rows: s? d?ng ??c l??ng, kh?ng ph?i s? d?ng th?c ?o.
--------------

--------------
-- ref: tra c?u kh?a kh?ng duy nh?t, kh?ng b?o ??m ch? m?t k?t qu?.
--------------

--------------
-- Index gh?p c? th? d?ng ti?n t? tr?i contactFirstName trong v? d? tr?n.
--------------

--------------
-- EXPLAIN ANALYZE ch?y truy v?n th?c t?, c?n MySQL 8.0.18 tr? l?n.
--------------

--------------
-- Kh?ng m?c ??nh Using filesort/Using temporary lu?n l? l?i hi?u n?ng.
--------------

--------------
-- Index l?m t?ng dung l??ng v? chi ph? INSERT/UPDATE/DELETE.
--------------


*/