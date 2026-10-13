-- [Thuc hanh] Tao CSDL tren MySQL Workbench
-- IF NOT EXISTS cho phep chay lai ma khong loi khi CSDL da ton tai.
CREATE DATABASE IF NOT EXISTS `my_database1`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Chon CSDL vua tao de su dung.
USE `my_database1`;

-- Kiem tra CSDL da duoc tao va dang duoc chon.
SHOW DATABASES LIKE 'my_database1';
SELECT DATABASE() AS current_database;
SHOW CREATE DATABASE `my_database1`;
