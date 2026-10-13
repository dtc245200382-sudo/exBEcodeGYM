-- [Bai tap] Xay dung CSDL quan ly ban hang
-- Giu dung cac bang va truong trong so do de bai.
CREATE DATABASE IF NOT EXISTS `QuanLyBanHang`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `QuanLyBanHang`;

-- Khach hang co the ton tai ma chua co hoa don.
CREATE TABLE `Customer` (
    `cID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cName` VARCHAR(100) NOT NULL,
    `cAge` INT,
    CONSTRAINT `CHK_Customer_Age` CHECK (`cAge` >= 0)
) ENGINE=InnoDB;

CREATE TABLE `Product` (
    `pID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `pName` VARCHAR(100) NOT NULL,
    `pPrice` DECIMAL(15,2) NOT NULL,
    CONSTRAINT `CHK_Product_Price` CHECK (`pPrice` >= 0)
) ENGINE=InnoDB;

-- Order la tu khoa SQL, can dat ten bang trong dau backtick.
-- Mot khach hang co the co nhieu hoa don.
CREATE TABLE `Order` (
    `oID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `cID` INT NOT NULL,
    `oDate` DATETIME NOT NULL,
    `oTotalPrice` DECIMAL(15,2) NOT NULL DEFAULT 0,
    CONSTRAINT `CHK_Order_TotalPrice` CHECK (`oTotalPrice` >= 0),
    CONSTRAINT `FK_Order_Customer` FOREIGN KEY (`cID`)
        REFERENCES `Customer` (`cID`)
) ENGINE=InnoDB;

-- Bang trung gian cho quan he nhieu-nhieu giua Order va Product.
-- PK ghep ngan mot san pham xuat hien thanh nhieu dong trong cung hoa don.
CREATE TABLE `OrderDetail` (
    `oID` INT NOT NULL,
    `pID` INT NOT NULL,
    `odQTY` INT NOT NULL,
    PRIMARY KEY (`oID`, `pID`),
    CONSTRAINT `CHK_OrderDetail_Quantity` CHECK (`odQTY` > 0),
    CONSTRAINT `FK_OrderDetail_Order` FOREIGN KEY (`oID`)
        REFERENCES `Order` (`oID`),
    CONSTRAINT `FK_OrderDetail_Product` FOREIGN KEY (`pID`)
        REFERENCES `Product` (`pID`)
) ENGINE=InnoDB;

-- So do khong co cot gia ban tai thoi diem mua trong OrderDetail.
-- oTotalPrice can duoc cap nhat khi ghi hoa don; DDL nay khong tu tinh tong.

-- Kiem tra cau truc, khoa chinh va khoa ngoai sau khi chay.
SHOW TABLES;
SHOW CREATE TABLE `Customer`;
SHOW CREATE TABLE `Product`;
SHOW CREATE TABLE `Order`;
SHOW CREATE TABLE `OrderDetail`;
