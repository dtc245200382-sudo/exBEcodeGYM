-- Chạy toàn bộ file trong MySQL Workbench trước khi mở ứng dụng.
CREATE DATABASE IF NOT EXISTS product_management_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_management_db;

CREATE TABLE IF NOT EXISTS products (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT chk_product_name CHECK (CHAR_LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT chk_product_quantity CHECK (quantity >= 0)
) ENGINE=InnoDB;

-- Dữ liệu mẫu chỉ được thêm khi bảng đang trống; không ghi đè dữ liệu đã có.
INSERT INTO products (name, price, quantity)
SELECT seed.name, seed.price, seed.quantity
FROM (
    SELECT 'Bàn phím cơ' AS name, 750000.00 AS price, 12 AS quantity
    UNION ALL SELECT 'Chuột không dây', 250000.00, 20
    UNION ALL SELECT 'Màn hình 24 inch', 3200000.00, 5
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM products);

SELECT id, name, price, quantity FROM products ORDER BY id;
