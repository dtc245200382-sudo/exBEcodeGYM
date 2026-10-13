-- [Thuc hanh] Tao bang trong CSDL QuanLyDiemThi
-- MaMH dung VARCHAR(50) theo bang mo ta cua de bai.
CREATE DATABASE IF NOT EXISTS `QuanLyDiemThi`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE `QuanLyDiemThi`;

CREATE TABLE `HocSinh` (
    `MaHS` VARCHAR(20) PRIMARY KEY,
    `TenHS` VARCHAR(50),
    `NgaySinh` DATETIME,
    `Lop` VARCHAR(20),
    `GT` VARCHAR(20)
) ENGINE=InnoDB;

-- Tao bang duoc tham chieu truoc bang MonHoc.
CREATE TABLE `GiaoVien` (
    `MaGV` VARCHAR(20) PRIMARY KEY,
    `TenGV` VARCHAR(50),
    `SDT` VARCHAR(10)
) ENGINE=InnoDB;

CREATE TABLE `MonHoc` (
    `MaMH` VARCHAR(50) PRIMARY KEY,
    `TenMH` VARCHAR(50),
    `MaGV` VARCHAR(20),
    CONSTRAINT `FK_MonHoc_GiaoVien`
        FOREIGN KEY (`MaGV`) REFERENCES `GiaoVien` (`MaGV`)
) ENGINE=InnoDB;

-- Bang trung gian cho quan he nhieu - nhieu giua HocSinh va MonHoc.
CREATE TABLE `BangDiem` (
    `MaHS` VARCHAR(20),
    `MaMH` VARCHAR(50),
    `DiemThi` INT,
    `NgayKT` DATETIME,
    PRIMARY KEY (`MaHS`, `MaMH`),
    CONSTRAINT `FK_BangDiem_HocSinh`
        FOREIGN KEY (`MaHS`) REFERENCES `HocSinh` (`MaHS`),
    CONSTRAINT `FK_BangDiem_MonHoc`
        FOREIGN KEY (`MaMH`) REFERENCES `MonHoc` (`MaMH`)
) ENGINE=InnoDB;

-- Kiem tra cac bang, khoa chinh va khoa ngoai sau khi chay.
SHOW TABLES;
SHOW CREATE TABLE `HocSinh`;
SHOW CREATE TABLE `GiaoVien`;
SHOW CREATE TABLE `MonHoc`;
SHOW CREATE TABLE `BangDiem`;
