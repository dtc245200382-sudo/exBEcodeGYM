-- FlashMart: khoi tao du lieu mau va hai bao cao JOIN.
-- Chay mot lan tren schema chua co cac bang nay; khong xoa du lieu cu.
CREATE DATABASE IF NOT EXISTS `flashmart_db`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `flashmart_db`;

CREATE TABLE `Customers` (
    `customer_id` INT PRIMARY KEY,
    `name` VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE `Products` (
    `product_id` INT PRIMARY KEY,
    `product_name` VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE `Orders` (
    `order_id` INT PRIMARY KEY,
    `customer_id` INT NOT NULL,
    `product_id` INT NOT NULL,
    INDEX `idx_orders_customer` (`customer_id`),
    INDEX `idx_orders_product` (`product_id`),
    CONSTRAINT `FK_Orders_Customers` FOREIGN KEY (`customer_id`)
        REFERENCES `Customers` (`customer_id`),
    CONSTRAINT `FK_Orders_Products` FOREIGN KEY (`product_id`)
        REFERENCES `Products` (`product_id`)
) ENGINE=InnoDB;

START TRANSACTION;
INSERT INTO `Customers` (`customer_id`, `name`)
VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie');

INSERT INTO `Products` (`product_id`, `product_name`)
VALUES (101, 'Laptop'), (102, 'Mouse'), (103, 'Keyboard');

INSERT INTO `Orders` (`order_id`, `customer_id`, `product_id`)
VALUES (1001, 1, 101), (1002, 1, 102), (1003, 2, 101);
COMMIT;

-- Bao cao 1: Customers la bang goc, giu ca khach chua mua hang.
-- Ket qua ky vong: (1, Alice, 2), (2, Bob, 1), (3, Charlie, 0).
SELECT c.`customer_id`, c.`name`, COUNT(o.`order_id`) AS `total_orders`
FROM `Customers` AS c
LEFT JOIN `Orders` AS o ON o.`customer_id` = c.`customer_id`
GROUP BY c.`customer_id`, c.`name`
ORDER BY c.`customer_id`;

-- Bao cao 2: Products la bang goc, chi lay san pham khong co don hang.
-- Ket qua ky vong: duy nhat (103, Keyboard).
SELECT p.`product_id`, p.`product_name`
FROM `Products` AS p
LEFT JOIN `Orders` AS o ON o.`product_id` = p.`product_id`
WHERE o.`order_id` IS NULL
ORDER BY p.`product_id`;
