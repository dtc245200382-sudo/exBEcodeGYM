# Bài nộp FlashMart: SQL, giải trình và nhật ký AI

Tài liệu này chứa nội dung của cả ba file theo yêu cầu để có thể đọc qua một liên kết.

## 1. flashmart_reports.sql

```sql
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

```

## 2. join_analysis.md

# Vì sao dùng COUNT(o.order_id)?

LEFT JOIN giữ tất cả khách hàng, kể cả khi không có đơn tương ứng. Với Charlie, các cột của Orders được bổ sung NULL. COUNT(*) đếm cả dòng này nên trả về 1, gây sai báo cáo. COUNT(o.order_id) bỏ qua NULL, do đó trả về 0; với Alice và Bob, kết quả lần lượt là 2 và 1.

INNER JOIN chỉ giữ các dòng khớp nên loại Charlie. Báo cáo sản phẩm chưa bán cần LEFT JOIN rồi lọc o.order_id IS NULL. Khóa chính order_id không thể NULL trong dữ liệu thật, vì vậy NULL ở đây chứng tỏ không có đơn tương ứng. INNER JOIN không tạo dòng không khớp nên bộ lọc này không tìm được Keyboard.


## 3. ai_prompt_log.md

# Nhật ký sử dụng AI

## Yêu cầu thực tế

Người dùng gửi toàn bộ đề FlashMart trong file đính kèm, trong ngữ cảnh yêu cầu chuẩn bị bài và đẩy GitHub. AI đọc đề, tạo SQL, phân tích và gói ZIP. Không có lượt hỏi đáp lý thuyết riêng; các prompt gợi ý trong đề không được ghi thành các câu hỏi đã thực sự trao đổi.

## Nội dung AI đã giải thích và áp dụng

- Customers là bảng gốc cho Marketing. LEFT JOIN giữ khách chưa mua; COUNT(order_id) không đếm dòng NULL được bổ sung.
- Products là bảng gốc cho Kho vận. LEFT JOIN và WHERE order_id IS NULL tìm sản phẩm không có giao dịch.
- INNER JOIN chỉ giữ các cặp khớp. RIGHT JOIN giữ Orders nếu không đổi thứ tự bảng nên không giữ được khách chưa có đơn.
- CROSS JOIN tạo tích Descartes; bỏ điều kiện nối hoặc dùng điều kiện luôn đúng có thể làm số dòng tăng mạnh. Hiệu năng phải được đo trên dữ liệu thực, không suy ra chỉ từ tên loại JOIN.
- Hai chỉ mục trên Orders hỗ trợ tra cứu theo customer_id và product_id. Chưa chạy EXPLAIN hoặc benchmark nên không tuyên bố truy vấn đã tối ưu nhất.
- NOT IN có thể cho kết quả ngoài mong muốn khi tập con chứa NULL. NOT EXISTS là lựa chọn khác cho kiểm tra không tồn tại; hiệu năng cần đối chiếu execution plan. Bài nộp dùng anti-join theo đề.

## Kiểm chứng và giới hạn

Đã đối chiếu thủ công dữ liệu mẫu: Marketing có Alice 2, Bob 1, Charlie 0; Kho vận có Keyboard (103). Đây là kết quả kỳ vọng, không phải kết quả chạy MySQL. Chưa có ảnh Result Grid thực tế; học viên cần chạy script và chụp kết quả để hoàn thành bước xác minh.

Script khởi tạo chạy một lần trên schema chưa có các bảng. Mô hình theo đề coi mỗi dòng Orders là một đơn có một sản phẩm; nếu mở rộng một đơn nhiều sản phẩm phải tách bảng chi tiết và rà soát cách đếm.

## Quy tắc AI trong đề

Đề chỉ cho phép AI giải thích và hỗ trợ tìm hiểu, không viết sẵn đáp án cuối cùng. Bản nháp này do AI tạo ở phạm vi rộng hơn quy tắc đó. Học viên cần tự rà soát, thực hành và trao đổi với giảng viên về mức dùng AI trước khi nộp; nhật ký không tuyên bố đây là bài tự làm.
