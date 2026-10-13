-- [Bai tap] Xay dung co so du lieu quan ly sinh vien
-- Dung schema student-management theo huong dan cua de bai.
-- Tao schema neu chua co de co the chay doc lap.
CREATE DATABASE IF NOT EXISTS `student-management`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `student-management`;

CREATE TABLE `Class` (
    `id` INT,
    `name` VARCHAR(200)
);

CREATE TABLE `Teacher` (
    `id` INT,
    `name` VARCHAR(200),
    `age` INT,
    `country` VARCHAR(50)
);

-- Kiem tra cac bang va cau truc sau khi tao.
SHOW TABLES;
DESCRIBE `Class`;
DESCRIBE `Teacher`;
