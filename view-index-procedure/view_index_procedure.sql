-- [Bài tập] View, Index, Stored Procedure
-- Một file chung. Chạy trên demo chưa có bảng Products và các đối tượng của bài.
CREATE DATABASE IF NOT EXISTS `demo`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `demo`;

CREATE TABLE `Products` (
    `Id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `productCode` VARCHAR(30) NOT NULL,
    `productName` VARCHAR(100) NOT NULL,
    `productPrice` DECIMAL(15,2) NOT NULL,
    `productAmount` INT NOT NULL,
    `productDescription` TEXT,
    `productStatus` BIT NOT NULL DEFAULT b'1',
    CONSTRAINT `CHK_Products_Price` CHECK (`productPrice` >= 0),
    CONSTRAINT `CHK_Products_Amount` CHECK (`productAmount` >= 0)
) ENGINE=InnoDB;

INSERT INTO `Products` (`productCode`, `productName`, `productPrice`,
    `productAmount`, `productDescription`, `productStatus`)
VALUES ('P001', 'Laptop', 15000000, 10, 'Laptop văn phòng', b'1'),
       ('P002', 'Mouse', 200000, 50, 'Chuột không dây', b'1'),
       ('P003', 'Keyboard', 500000, 30, 'Bàn phím cơ', b'1'),
       ('P004', 'Monitor', 3000000, 20, 'Màn hình 24 inch', b'1'),
       ('P005', 'Headphones', 700000, 15, 'Tai nghe', b'0');

-- 3. So sánh cùng truy vấn trước và sau khi tạo index.
EXPLAIN SELECT * FROM `Products` WHERE `productCode` = 'P003';
EXPLAIN SELECT * FROM `Products`
WHERE `productName` = 'Mouse' AND `productPrice` = 200000;

CREATE UNIQUE INDEX `idx_productCode` ON `Products` (`productCode`);
CREATE INDEX `idx_productName_productPrice`
ON `Products` (`productName`, `productPrice`);
ANALYZE TABLE `Products`;

EXPLAIN SELECT * FROM `Products` WHERE `productCode` = 'P003';
EXPLAIN SELECT * FROM `Products`
WHERE `productName` = 'Mouse' AND `productPrice` = 200000;
SHOW INDEX FROM `Products`;

-- 4. Tạo, truy vấn, sửa định nghĩa và xoá view.
CREATE VIEW `product_view` AS
SELECT `productCode`, `productName`, `productPrice`, `productStatus`
FROM `Products`;
SELECT * FROM `product_view` ORDER BY `productCode`;

CREATE OR REPLACE VIEW `product_view` AS
SELECT `productCode`, `productName`, `productPrice`, `productStatus`
FROM `Products` WHERE `productStatus` = b'1';
SELECT * FROM `product_view` ORDER BY `productCode`;
DROP VIEW `product_view`;

-- 5. Stored procedure: xem, thêm, sửa, xoá sản phẩm.
DELIMITER //
CREATE PROCEDURE `getAllProducts`()
BEGIN
    SELECT * FROM `Products` ORDER BY `Id`;
END//

CREATE PROCEDURE `addProduct`(
    IN p_code VARCHAR(30), IN p_name VARCHAR(100),
    IN p_price DECIMAL(15,2), IN p_amount INT,
    IN p_description TEXT, IN p_status BIT
)
BEGIN
    INSERT INTO `Products` (`productCode`, `productName`, `productPrice`,
        `productAmount`, `productDescription`, `productStatus`)
    VALUES (p_code, p_name, p_price, p_amount, p_description, p_status);
END//

CREATE PROCEDURE `updateProduct`(
    IN p_id INT, IN p_code VARCHAR(30), IN p_name VARCHAR(100),
    IN p_price DECIMAL(15,2), IN p_amount INT,
    IN p_description TEXT, IN p_status BIT
)
BEGIN
    UPDATE `Products`
    SET `productCode` = p_code, `productName` = p_name,
        `productPrice` = p_price, `productAmount` = p_amount,
        `productDescription` = p_description, `productStatus` = p_status
    WHERE `Id` = p_id;
END//

CREATE PROCEDURE `deleteProduct`(IN p_id INT)
BEGIN
    DELETE FROM `Products` WHERE `Id` = p_id;
END//
DELIMITER ;

-- Demo CRUD trên sản phẩm mới; giữ nguyên 5 sản phẩm mẫu.
CALL `getAllProducts`();
CALL `addProduct`('P006', 'USB', 100000, 25, 'USB 32GB', b'1');
SET @new_product_id = LAST_INSERT_ID();
SELECT * FROM `Products` WHERE `Id` = @new_product_id;

CALL `updateProduct`(@new_product_id, 'P006', 'USB 64GB', 180000, 20,
    'Đã cập nhật dung lượng USB', b'1');
SELECT * FROM `Products` WHERE `Id` = @new_product_id;

CALL `deleteProduct`(@new_product_id);
SELECT COUNT(*) AS `DeletedProductRemaining`
FROM `Products` WHERE `Id` = @new_product_id;
SELECT COUNT(*) AS `FinalProductCount` FROM `Products`;

-- EXPLAIN.rows là ước lượng. Dữ liệu mẫu nhỏ chưa đủ đánh giá tốc độ thực tế.
-- Unique index bảo đảm mã sản phẩm không trùng; composite index dùng tiền tố trái.

-- KẾT QUẢ THỰC TẾ: MySQL 8.4.11, server thử riêng.
-- productCode: ALL, rows=5 -> const, rows=1, key=idx_productCode.
-- productName + productPrice: ALL, rows=5 -> ref, rows=1, key=idx_productName_productPrice.
-- View ban đầu: 5 dòng; view sau sửa: 4 sản phẩm đang hoạt động; đã DROP VIEW.
-- CRUD thành công: thêm USB, sửa USB 64GB giá 180000, xoá sản phẩm vừa thêm.
-- Sau xoá: DeletedProductRemaining=0; FinalProductCount=5.
-- Log console bên dưới; ký tự BIT điều khiển được biểu diễn bằng [BIT 0]/[BIT 1].

/*
--------------
-- [B?i t?p] View, Index, Stored Procedure
--------------

--------------
-- M?t file chung. Ch?y tr?n demo ch?a c? b?ng Products v? c?c ??i t??ng c?a b?i.
--------------

--------------
CREATE DATABASE IF NOT EXISTS `demo`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
--------------

--------------
CREATE TABLE `Products` (
    `Id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `productCode` VARCHAR(30) NOT NULL,
    `productName` VARCHAR(100) NOT NULL,
    `productPrice` DECIMAL(15,2) NOT NULL,
    `productAmount` INT NOT NULL,
    `productDescription` TEXT,
    `productStatus` BIT NOT NULL DEFAULT b'1',
    CONSTRAINT `CHK_Products_Price` CHECK (`productPrice` >= 0),
    CONSTRAINT `CHK_Products_Amount` CHECK (`productAmount` >= 0)
) ENGINE=InnoDB
--------------

--------------
INSERT INTO `Products` (`productCode`, `productName`, `productPrice`,
    `productAmount`, `productDescription`, `productStatus`)
VALUES ('P001', 'Laptop', 15000000, 10, 'Laptop v?n ph?ng', b'1'),
       ('P002', 'Mouse', 200000, 50, 'Chu?t kh?ng d?y', b'1'),
       ('P003', 'Keyboard', 500000, 30, 'B?n ph?m c?', b'1'),
       ('P004', 'Monitor', 3000000, 20, 'M?n h?nh 24 inch', b'1'),
       ('P005', 'Headphones', 700000, 15, 'Tai nghe', b'0')
--------------

--------------
-- 3. So s?nh c?ng truy v?n tr??c v? sau khi t?o index.
--------------

--------------
EXPLAIN SELECT * FROM `Products` WHERE `productCode` = 'P003'
--------------

+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Products | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    5 |    20.00 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
--------------
EXPLAIN SELECT * FROM `Products`
WHERE `productName` = 'Mouse' AND `productPrice` = 200000
--------------

+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
| id | select_type | table    | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
|  1 | SIMPLE      | Products | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    5 |    20.00 | Using where |
+----+-------------+----------+------------+------+---------------+------+---------+------+------+----------+-------------+
--------------
CREATE UNIQUE INDEX `idx_productCode` ON `Products` (`productCode`)
--------------

--------------
CREATE INDEX `idx_productName_productPrice`
ON `Products` (`productName`, `productPrice`)
--------------

--------------
ANALYZE TABLE `Products`
--------------

+---------------+---------+----------+----------+
| Table         | Op      | Msg_type | Msg_text |
+---------------+---------+----------+----------+
| demo.products | analyze | status   | OK       |
+---------------+---------+----------+----------+
--------------
EXPLAIN SELECT * FROM `Products` WHERE `productCode` = 'P003'
--------------

+----+-------------+----------+------------+-------+-----------------+-----------------+---------+-------+------+----------+-------+
| id | select_type | table    | partitions | type  | possible_keys   | key             | key_len | ref   | rows | filtered | Extra |
+----+-------------+----------+------------+-------+-----------------+-----------------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | Products | NULL       | const | idx_productCode | idx_productCode | 122     | const |    1 |   100.00 | NULL  |
+----+-------------+----------+------------+-------+-----------------+-----------------+---------+-------+------+----------+-------+
--------------
EXPLAIN SELECT * FROM `Products`
WHERE `productName` = 'Mouse' AND `productPrice` = 200000
--------------

+----+-------------+----------+------------+------+------------------------------+------------------------------+---------+-------------+------+----------+-------+
| id | select_type | table    | partitions | type | possible_keys                | key                          | key_len | ref         | rows | filtered | Extra |
+----+-------------+----------+------------+------+------------------------------+------------------------------+---------+-------------+------+----------+-------+
|  1 | SIMPLE      | Products | NULL       | ref  | idx_productName_productPrice | idx_productName_productPrice | 409     | const,const |    1 |   100.00 | NULL  |
+----+-------------+----------+------------+------+------------------------------+------------------------------+---------+-------------+------+----------+-------+
--------------
SHOW INDEX FROM `Products`
--------------

+----------+------------+------------------------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| Table    | Non_unique | Key_name                     | Seq_in_index | Column_name  | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Visible | Expression |
+----------+------------+------------------------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
| products |          0 | PRIMARY                      |            1 | Id           | A         |           5 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| products |          0 | idx_productCode              |            1 | productCode  | A         |           5 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| products |          1 | idx_productName_productPrice |            1 | productName  | A         |           5 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
| products |          1 | idx_productName_productPrice |            2 | productPrice | A         |           5 |     NULL |   NULL |      | BTREE      |         |               | YES     | NULL       |
+----------+------------+------------------------------+--------------+--------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+------------+
--------------
-- 4. T?o, truy v?n, s?a ??nh ngh?a v? xo? view.
--------------

--------------
CREATE VIEW `product_view` AS
SELECT `productCode`, `productName`, `productPrice`, `productStatus`
FROM `Products`
--------------

--------------
SELECT * FROM `product_view` ORDER BY `productCode`
--------------

+-------------+-------------+--------------+---------------+
| productCode | productName | productPrice | productStatus |
+-------------+-------------+--------------+---------------+
| P001        | Laptop      |  15000000.00 | [BIT 1]             |
| P002        | Mouse       |    200000.00 | [BIT 1]             |
| P003        | Keyboard    |    500000.00 | [BIT 1]             |
| P004        | Monitor     |   3000000.00 | [BIT 1]             |
| P005        | Headphones  |    700000.00 |               |
+-------------+-------------+--------------+---------------+
--------------
CREATE OR REPLACE VIEW `product_view` AS
SELECT `productCode`, `productName`, `productPrice`, `productStatus`
FROM `Products` WHERE `productStatus` = b'1'
--------------

--------------
SELECT * FROM `product_view` ORDER BY `productCode`
--------------

+-------------+-------------+--------------+---------------+
| productCode | productName | productPrice | productStatus |
+-------------+-------------+--------------+---------------+
| P001        | Laptop      |  15000000.00 | [BIT 1]             |
| P002        | Mouse       |    200000.00 | [BIT 1]             |
| P003        | Keyboard    |    500000.00 | [BIT 1]             |
| P004        | Monitor     |   3000000.00 | [BIT 1]             |
+-------------+-------------+--------------+---------------+
--------------
DROP VIEW `product_view`
--------------

--------------
-- 5. Stored procedure: xem, th?m, s?a, xo? s?n ph?m.
--------------

--------------
CREATE PROCEDURE `getAllProducts`()
BEGIN
    SELECT * FROM `Products` ORDER BY `Id`;
END
--------------

--------------
CREATE PROCEDURE `addProduct`(
    IN p_code VARCHAR(30), IN p_name VARCHAR(100),
    IN p_price DECIMAL(15,2), IN p_amount INT,
    IN p_description TEXT, IN p_status BIT
)
BEGIN
    INSERT INTO `Products` (`productCode`, `productName`, `productPrice`,
        `productAmount`, `productDescription`, `productStatus`)
    VALUES (p_code, p_name, p_price, p_amount, p_description, p_status);
END
--------------

--------------
CREATE PROCEDURE `updateProduct`(
    IN p_id INT, IN p_code VARCHAR(30), IN p_name VARCHAR(100),
    IN p_price DECIMAL(15,2), IN p_amount INT,
    IN p_description TEXT, IN p_status BIT
)
BEGIN
    UPDATE `Products`
    SET `productCode` = p_code, `productName` = p_name,
        `productPrice` = p_price, `productAmount` = p_amount,
        `productDescription` = p_description, `productStatus` = p_status
    WHERE `Id` = p_id;
END
--------------

--------------
CREATE PROCEDURE `deleteProduct`(IN p_id INT)
BEGIN
    DELETE FROM `Products` WHERE `Id` = p_id;
END
--------------

--------------
-- Demo CRUD tr?n s?n ph?m m?i; gi? nguy?n 5 s?n ph?m m?u.
--------------

--------------
CALL `getAllProducts`()
--------------

+----+-------------+-------------+--------------+---------------+--------------------+---------------+
| Id | productCode | productName | productPrice | productAmount | productDescription | productStatus |
+----+-------------+-------------+--------------+---------------+--------------------+---------------+
|  1 | P001        | Laptop      |  15000000.00 |            10 | Laptop v?n ph?ng   | [BIT 1]             |
|  2 | P002        | Mouse       |    200000.00 |            50 | Chu?t kh?ng d?y    | [BIT 1]             |
|  3 | P003        | Keyboard    |    500000.00 |            30 | B?n ph?m c?        | [BIT 1]             |
|  4 | P004        | Monitor     |   3000000.00 |            20 | M?n h?nh 24 inch   | [BIT 1]             |
|  5 | P005        | Headphones  |    700000.00 |            15 | Tai nghe           |               |
+----+-------------+-------------+--------------+---------------+--------------------+---------------+
--------------
CALL `addProduct`('P006', 'USB', 100000, 25, 'USB 32GB', b'1')
--------------

--------------
SET @new_product_id = LAST_INSERT_ID()
--------------

--------------
SELECT * FROM `Products` WHERE `Id` = @new_product_id
--------------

+----+-------------+-------------+--------------+---------------+--------------------+---------------+
| Id | productCode | productName | productPrice | productAmount | productDescription | productStatus |
+----+-------------+-------------+--------------+---------------+--------------------+---------------+
|  6 | P006        | USB         |    100000.00 |            25 | USB 32GB           | [BIT 1]             |
+----+-------------+-------------+--------------+---------------+--------------------+---------------+
--------------
CALL `updateProduct`(@new_product_id, 'P006', 'USB 64GB', 180000, 20,
    '?? c?p nh?t dung l??ng USB', b'1')
--------------

--------------
SELECT * FROM `Products` WHERE `Id` = @new_product_id
--------------

+----+-------------+-------------+--------------+---------------+----------------------------+---------------+
| Id | productCode | productName | productPrice | productAmount | productDescription         | productStatus |
+----+-------------+-------------+--------------+---------------+----------------------------+---------------+
|  6 | P006        | USB 64GB    |    180000.00 |            20 | ?? c?p nh?t dung l??ng USB | [BIT 1]             |
+----+-------------+-------------+--------------+---------------+----------------------------+---------------+
--------------
CALL `deleteProduct`(@new_product_id)
--------------

--------------
SELECT COUNT(*) AS `DeletedProductRemaining`
FROM `Products` WHERE `Id` = @new_product_id
--------------

+-------------------------+
| DeletedProductRemaining |
+-------------------------+
|                       0 |
+-------------------------+
--------------
SELECT COUNT(*) AS `FinalProductCount` FROM `Products`
--------------

+-------------------+
| FinalProductCount |
+-------------------+
|                 5 |
+-------------------+
--------------
-- EXPLAIN.rows l? ??c l??ng. D? li?u m?u nh? ch?a ?? ??nh gi? t?c ?? th?c t?.
--------------

--------------
-- Unique index b?o ??m m? s?n ph?m kh?ng tr?ng; composite index d?ng ti?n t? tr?i.
--------------


*/