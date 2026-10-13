-- [Thực hành] Trigger trong MySQL
-- Một file chung: tạo CSDL, bảng, trigger, dữ liệu demo và kiểm tra.
-- Chạy một lần trên CSDL chưa có bảng employees của bài này.
CREATE DATABASE IF NOT EXISTS `company`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `company`;

CREATE TABLE `employees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `department` VARCHAR(50) NOT NULL,
    `salary` DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;

-- BEFORE INSERT thay đổi NEW.department trước khi lưu từng dòng.
DELIMITER //
CREATE TRIGGER `update_department`
BEFORE INSERT ON `employees`
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END//
DELIMITER ;

INSERT INTO `employees` (`name`, `department`, `salary`)
VALUES ('John Doe', 'A', 3500),
       ('Jane Smith', 'A', 2000),
       ('David Johnson', 'A', 6000);

-- Kết quả mong đợi: John = Sales, Jane = Support, David = Management.
SELECT `id`, `name`, `department`, `salary`
FROM `employees`
ORDER BY `id`;

SHOW CREATE TRIGGER `update_department`;

-- Kiểm tra các ngưỡng; ROLLBACK để không giữ dữ liệu thử trong bảng.
START TRANSACTION;
INSERT INTO `employees` (`name`, `department`, `salary`)
VALUES ('Boundary 2999.99', 'A', 2999.99),
       ('Boundary 3000', 'A', 3000),
       ('Boundary 4999.99', 'A', 4999.99),
       ('Boundary 5000', 'A', 5000);

SELECT `name`, `salary`, `department`
FROM `employees`
WHERE `name` LIKE 'Boundary %'
ORDER BY `salary`;
ROLLBACK;

SELECT COUNT(*) AS `SoNhanVienSauKiemTra` FROM `employees`;
-- Trigger này chỉ áp dụng INSERT, không tự đổi phòng ban khi UPDATE lương.

-- KẾT QUẢ THỰC TẾ: MySQL 8.4.11, server thử riêng.
-- John Doe: Sales; Jane Smith: Support; David Johnson: Management.
-- Ngưỡng 2999.99: Support; 3000 và 4999.99: Sales; 5000: Management.
-- Sau rollback dữ liệu thử, bảng còn 3 nhân viên demo.
-- Log console thực tế bên dưới, đặt trong comment.

/*
--------------
-- [Th?c h?nh] Trigger trong MySQL
--------------

--------------
-- M?t file chung: t?o CSDL, b?ng, trigger, d? li?u demo v? ki?m tra.
--------------

--------------
-- Ch?y m?t l?n tr?n CSDL ch?a c? b?ng employees c?a b?i n?y.
--------------

--------------
CREATE DATABASE IF NOT EXISTS `company`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
--------------

--------------
CREATE TABLE `employees` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `department` VARCHAR(50) NOT NULL,
    `salary` DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB
--------------

--------------
-- BEFORE INSERT thay ??i NEW.department tr??c khi l?u t?ng d?ng.
--------------

--------------
CREATE TRIGGER `update_department`
BEFORE INSERT ON `employees`
FOR EACH ROW
BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END
--------------

--------------
INSERT INTO `employees` (`name`, `department`, `salary`)
VALUES ('John Doe', 'A', 3500),
       ('Jane Smith', 'A', 2000),
       ('David Johnson', 'A', 6000)
--------------

--------------
-- K?t qu? mong ??i: John = Sales, Jane = Support, David = Management.
--------------

--------------
SELECT `id`, `name`, `department`, `salary`
FROM `employees`
ORDER BY `id`
--------------

+----+---------------+------------+---------+
| id | name          | department | salary  |
+----+---------------+------------+---------+
|  1 | John Doe      | Sales      | 3500.00 |
|  2 | Jane Smith    | Support    | 2000.00 |
|  3 | David Johnson | Management | 6000.00 |
+----+---------------+------------+---------+
--------------
SHOW CREATE TRIGGER `update_department`
--------------

+-------------------+-----------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+------------------------+
| Trigger           | sql_mode                                                                                                              | SQL Original Statement                                                                                                                                                                                                                                                                                                            | character_set_client | collation_connection | Database Collation | Created                |
+-------------------+-----------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+------------------------+
| update_department | ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION | CREATE DEFINER=`root`@`localhost` TRIGGER `update_department` BEFORE INSERT ON `employees` FOR EACH ROW BEGIN
    IF NEW.salary >= 5000 THEN
        SET NEW.department = 'Management';
    ELSEIF NEW.salary >= 3000 THEN
        SET NEW.department = 'Sales';
    ELSE
        SET NEW.department = 'Support';
    END IF;
END | utf8mb4              | utf8mb4_0900_ai_ci   | utf8mb4_unicode_ci | 2026-10-13 15:07:11.76 |
+-------------------+-----------------------------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+----------------------+----------------------+--------------------+------------------------+
--------------
-- Ki?m tra c?c ng??ng; ROLLBACK ?? kh?ng gi? d? li?u th? trong b?ng.
--------------

--------------
START TRANSACTION
--------------

--------------
INSERT INTO `employees` (`name`, `department`, `salary`)
VALUES ('Boundary 2999.99', 'A', 2999.99),
       ('Boundary 3000', 'A', 3000),
       ('Boundary 4999.99', 'A', 4999.99),
       ('Boundary 5000', 'A', 5000)
--------------

--------------
SELECT `name`, `salary`, `department`
FROM `employees`
WHERE `name` LIKE 'Boundary %'
ORDER BY `salary`
--------------

+------------------+---------+------------+
| name             | salary  | department |
+------------------+---------+------------+
| Boundary 2999.99 | 2999.99 | Support    |
| Boundary 3000    | 3000.00 | Sales      |
| Boundary 4999.99 | 4999.99 | Sales      |
| Boundary 5000    | 5000.00 | Management |
+------------------+---------+------------+
--------------
ROLLBACK
--------------

--------------
SELECT COUNT(*) AS `SoNhanVienSauKiemTra` FROM `employees`
--------------

+----------------------+
| SoNhanVienSauKiemTra |
+----------------------+
|                    3 |
+----------------------+
--------------
-- Trigger n?y ch? ?p d?ng INSERT, kh?ng t? ??i ph?ng ban khi UPDATE l??ng.
--------------


*/