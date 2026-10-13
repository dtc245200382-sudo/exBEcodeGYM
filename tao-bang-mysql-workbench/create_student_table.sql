-- [Thuc hanh] Tao bang tren MySQL Workbench
-- Chay tung cau lenh trong New Query Tab.

CREATE DATABASE `demo`;

USE `demo`;

CREATE TABLE `Student` (
    `id` INT,
    `name` VARCHAR(200),
    `age` INT,
    `country` VARCHAR(50)
);

-- Kiem tra bang va cac truong vua tao.
SHOW TABLES;
DESCRIBE `Student`;
