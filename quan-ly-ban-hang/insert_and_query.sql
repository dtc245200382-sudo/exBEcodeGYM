-- [Bài tập] Thao tác với CSDL Quản lý bán hàng
-- Chạy create_database.sql trước, rồi chạy phần INSERT một lần.
-- Nếu đã thêm dữ liệu mẫu, chỉ chạy phần truy vấn bên dưới.
USE `QuanLyBanHang`;

-- Schema trước dùng cName cho tên khách hàng và DECIMAL cho tiền.
-- Cho phép tổng tiền chưa được tính là NULL, đúng dữ liệu mẫu của đề.
ALTER TABLE `Order`
    MODIFY COLUMN `oTotalPrice` DECIMAL(15,2) NULL DEFAULT NULL;

START TRANSACTION;

INSERT INTO `Customer` (`cID`, `cName`, `cAge`)
VALUES (1, 'Minh Quan', 10),
       (2, 'Ngoc Oanh', 20),
       (3, 'Hong Ha', 50);

INSERT INTO `Product` (`pID`, `pName`, `pPrice`)
VALUES (1, 'May Giat', 3),
       (2, 'Tu Lanh', 5),
       (3, 'Dieu Hoa', 7),
       (4, 'Quat', 1),
       (5, 'Bep Dien', 2);

INSERT INTO `Order` (`oID`, `cID`, `oDate`, `oTotalPrice`)
VALUES (1, 1, '2006-03-21', NULL),
       (2, 2, '2006-03-23', NULL),
       (3, 1, '2006-03-16', NULL);

INSERT INTO `OrderDetail` (`oID`, `pID`, `odQTY`)
VALUES (1, 1, 3),
       (1, 3, 7),
       (1, 4, 2),
       (2, 1, 1),
       (3, 1, 8),
       (2, 5, 4),
       (2, 3, 3);

COMMIT;

-- 1. Hiển thị mã, ngày và giá của tất cả hóa đơn.
-- Đề gọi oPrice; tên cột trong schema là oTotalPrice.
SELECT `oID`, `oDate`, `oTotalPrice` AS `oPrice`
FROM `Order`
ORDER BY `oID`;

-- 2. Hiển thị khách hàng đã mua hàng và các sản phẩm họ mua.
-- DISTINCT để mỗi cặp khách hàng - sản phẩm chỉ xuất hiện một lần.
SELECT DISTINCT c.`cID`, c.`cName`, p.`pID`, p.`pName`
FROM `Customer` AS c
JOIN `Order` AS o ON o.`cID` = c.`cID`
JOIN `OrderDetail` AS od ON od.`oID` = o.`oID`
JOIN `Product` AS p ON p.`pID` = od.`pID`
ORDER BY c.`cID`, p.`pID`;

-- 3. Hiển thị tên khách hàng không mua bất kỳ sản phẩm nào.
-- Kiểm tra cả chi tiết hóa đơn: hóa đơn trống không được coi là mua sản phẩm.
SELECT c.`cName`
FROM `Customer` AS c
WHERE NOT EXISTS (
    SELECT 1
    FROM `Order` AS o
    JOIN `OrderDetail` AS od ON od.`oID` = o.`oID`
    WHERE o.`cID` = c.`cID`
)
ORDER BY c.`cID`;

-- 4. Tính giá từng hóa đơn bằng tổng (số lượng * giá sản phẩm).
-- LEFT JOIN giữ cả hóa đơn chưa có chi tiết; tổng khi đó là 0.
SELECT o.`oID`, o.`oDate`,
       COALESCE(SUM(od.`odQTY` * p.`pPrice`), 0) AS `oPrice`
FROM `Order` AS o
LEFT JOIN `OrderDetail` AS od ON od.`oID` = o.`oID`
LEFT JOIN `Product` AS p ON p.`pID` = od.`pID`
GROUP BY o.`oID`, o.`oDate`
ORDER BY o.`oID`;

-- Kết quả kỳ vọng: khách chưa mua là Hong Ha.
-- Tổng hóa đơn 1 = 60; hóa đơn 2 = 32; hóa đơn 3 = 24.
-- Truy vấn 4 tính tổng khi đọc, không cập nhật oTotalPrice đang NULL.
