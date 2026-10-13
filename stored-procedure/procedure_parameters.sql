-- [Thực hành] Truyền tham số vào Stored Procedure
-- Dùng CSDL classicmodels đã import từ bài trước.
-- Một file chung gồm IN, OUT, INOUT và các lệnh gọi kiểm tra.
USE `classicmodels`;

-- 1. IN: nhận mã khách hàng từ bên ngoài.
DELIMITER //
DROP PROCEDURE IF EXISTS `getCusById`//
CREATE PROCEDURE `getCusById`(IN cusNum INT)
BEGIN
    SELECT * FROM `customers` WHERE `customerNumber` = cusNum;
END//
DELIMITER ;

CALL `getCusById`(175);

-- 2. OUT: trả số lượng khách hàng tại một thành phố vào biến phiên.
DELIMITER //
DROP PROCEDURE IF EXISTS `GetCustomersCountByCity`//
CREATE PROCEDURE `GetCustomersCountByCity`(
    IN in_city VARCHAR(50),
    OUT total INT
)
BEGIN
    SELECT COUNT(`customerNumber`) INTO total
    FROM `customers`
    WHERE `city` = in_city;
END//
DELIMITER ;

CALL `GetCustomersCountByCity`('Lyon', @total);
SELECT @total AS `CustomersInLyon`;

-- 3. INOUT: nhận giá trị ban đầu và trả lại giá trị đã thay đổi.
DELIMITER //
DROP PROCEDURE IF EXISTS `SetCounter`//
CREATE PROCEDURE `SetCounter`(INOUT counter INT, IN inc INT)
BEGIN
    SET counter = counter + inc;
END//
DELIMITER ;

SET @counter = 1;
CALL `SetCounter`(@counter, 1);
SELECT @counter AS `CounterAfterFirstCall`; -- 2
CALL `SetCounter`(@counter, 1);
SELECT @counter AS `CounterAfterSecondCall`; -- 3
CALL `SetCounter`(@counter, 5);
SELECT @counter AS `CounterAfterThirdCall`; -- 8

-- IN: giá trị đầu vào; OUT: giá trị đầu ra, khởi tạo NULL trong thủ tục.
-- INOUT: dùng giá trị đầu vào rồi chuyển giá trị sau xử lý về bên gọi.
-- @total và @counter là biến phiên trong ví dụ CALL từ MySQL client.

-- Kết quả thực tế trên MySQL 8.4.11, dữ liệu classicmodels mẫu:
-- IN: mã 175 trả về Gift Depot Inc.
-- OUT: Lyon có 1 khách hàng.
-- INOUT: lần lượt 2, 3, 8.
-- Log console thật bên dưới được đặt trong comment.

/*
--------------
-- [Th?c h?nh] Truy?n tham s? v?o Stored Procedure
--------------

--------------
-- D?ng CSDL classicmodels ?? import t? b?i tr??c.
--------------

--------------
-- M?t file chung g?m IN, OUT, INOUT v? c?c l?nh g?i ki?m tra.
--------------

--------------
-- 1. IN: nh?n m? kh?ch h?ng t? b?n ngo?i.
--------------

--------------
DROP PROCEDURE IF EXISTS `getCusById`
--------------

--------------
CREATE PROCEDURE `getCusById`(IN cusNum INT)
BEGIN
    SELECT * FROM `customers` WHERE `customerNumber` = cusNum;
END
--------------

--------------
CALL `getCusById`(175)
--------------

+----------------+-----------------+-----------------+------------------+------------+---------------------+--------------+-------------+-------+------------+---------+------------------------+-------------+
| customerNumber | customerName    | contactLastName | contactFirstName | phone      | addressLine1        | addressLine2 | city        | state | postalCode | country | salesRepEmployeeNumber | creditLimit |
+----------------+-----------------+-----------------+------------------+------------+---------------------+--------------+-------------+-------+------------+---------+------------------------+-------------+
|            175 | Gift Depot Inc. | King            | Julie            | 2035552570 | 25593 South Bay Ln. | NULL         | Bridgewater | CT    | 97562      | USA     |                   1323 |    84300.00 |
+----------------+-----------------+-----------------+------------------+------------+---------------------+--------------+-------------+-------+------------+---------+------------------------+-------------+
--------------
-- 2. OUT: tr? s? l??ng kh?ch h?ng t?i m?t th?nh ph? v?o bi?n phi?n.
--------------

--------------
DROP PROCEDURE IF EXISTS `GetCustomersCountByCity`
--------------

--------------
CREATE PROCEDURE `GetCustomersCountByCity`(
    IN in_city VARCHAR(50),
    OUT total INT
)
BEGIN
    SELECT COUNT(`customerNumber`) INTO total
    FROM `customers`
    WHERE `city` = in_city;
END
--------------

--------------
CALL `GetCustomersCountByCity`('Lyon', @total)
--------------

--------------
SELECT @total AS `CustomersInLyon`
--------------

+-----------------+
| CustomersInLyon |
+-----------------+
|               1 |
+-----------------+
--------------
-- 3. INOUT: nh?n gi? tr? ban ??u v? tr? l?i gi? tr? ?? thay ??i.
--------------

--------------
DROP PROCEDURE IF EXISTS `SetCounter`
--------------

--------------
CREATE PROCEDURE `SetCounter`(INOUT counter INT, IN inc INT)
BEGIN
    SET counter = counter + inc;
END
--------------

--------------
SET @counter = 1
--------------

--------------
CALL `SetCounter`(@counter, 1)
--------------

--------------
SELECT @counter AS `CounterAfterFirstCall` -- 2
--------------

+-----------------------+
| CounterAfterFirstCall |
+-----------------------+
|                     2 |
+-----------------------+
--------------
CALL `SetCounter`(@counter, 1)
--------------

--------------
SELECT @counter AS `CounterAfterSecondCall` -- 3
--------------

+------------------------+
| CounterAfterSecondCall |
+------------------------+
|                      3 |
+------------------------+
--------------
CALL `SetCounter`(@counter, 5)
--------------

--------------
SELECT @counter AS `CounterAfterThirdCall` -- 8
--------------

+-----------------------+
| CounterAfterThirdCall |
+-----------------------+
|                     8 |
+-----------------------+
--------------
-- IN: gi? tr? ??u v?o; OUT: gi? tr? ??u ra, kh?i t?o NULL trong th? t?c.
--------------

--------------
-- INOUT: d?ng gi? tr? ??u v?o r?i chuy?n gi? tr? sau x? l? v? b?n g?i.
--------------

--------------
-- @total v? @counter l? bi?n phi?n trong v? d? CALL t? MySQL client.
--------------


*/