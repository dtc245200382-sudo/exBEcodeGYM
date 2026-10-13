CREATE DATABASE IF NOT EXISTS `inotes_db`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `inotes_db`;

CREATE TABLE IF NOT EXISTS `note_type` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `description` VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `notes` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `content` TEXT,
    `type_id` INT NOT NULL,
    CONSTRAINT `FK_Notes_Type` FOREIGN KEY (`type_id`)
        REFERENCES `note_type` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Không ghi đè danh mục có sẵn khi chạy lại.
INSERT IGNORE INTO `note_type` (`id`, `name`, `description`)
VALUES (1, 'Cá nhân', 'Ghi chú cá nhân'),
       (2, 'Công việc', 'Công việc cần ghi nhớ'),
       (3, 'Học tập', 'Nội dung học tập');
