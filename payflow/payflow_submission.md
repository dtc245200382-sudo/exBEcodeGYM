# Bài nộp PayFlow

## 1. payflow_optimized.sql

```sql
-- PayFlow: so sanh EXPLAIN truoc/sau khi them index.
-- CREATE INDEX chi chay mot lan; neu da co idx_type_date, bo qua buoc tao index.
-- Script khong gia lap 5 trieu dong va khong xoa du lieu hien co.
CREATE DATABASE IF NOT EXISTS `payflow_db`;
USE `payflow_db`;

CREATE TABLE IF NOT EXISTS `Transactions` (
    `transaction_id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    `amount` DECIMAL(15,2),
    `transaction_type` VARCHAR(20),
    `created_at` DATETIME
) ENGINE=InnoDB;

-- 1. Ke hoach legacy TRUOC khi tao index (tren schema legacy trong de).
EXPLAIN
SELECT SUM(`amount`) AS `total_deposit`
FROM `Transactions`
WHERE `transaction_type` = 'DEPOSIT'
  AND YEAR(`created_at`) = 2026
  AND MONTH(`created_at`) = 6;

-- 2. Cot so sanh bang dung truoc, cot so sanh khoang dung sau.
CREATE INDEX `idx_type_date`
ON `Transactions` (`transaction_type`, `created_at`);

ANALYZE TABLE `Transactions`;

-- 3. Ke hoach legacy SAU khi tao index de tach tac dong cua index va refactor.
EXPLAIN
SELECT SUM(`amount`) AS `total_deposit`
FROM `Transactions`
WHERE `transaction_type` = 'DEPOSIT'
  AND YEAR(`created_at`) = 2026
  AND MONTH(`created_at`) = 6;

-- 4. Ke hoach truy van toi uu: khoang nua mo, khong boc ham tren cot ngay.
EXPLAIN
SELECT SUM(`amount`) AS `total_deposit`
FROM `Transactions`
WHERE `transaction_type` = 'DEPOSIT'
  AND `created_at` >= '2026-06-01 00:00:00'
  AND `created_at` <  '2026-07-01 00:00:00';

-- 5. Bao cao thuc te: giu SUM va cach xu ly NULL nhu truy van cu.
SELECT SUM(`amount`) AS `total_deposit`
FROM `Transactions`
WHERE `transaction_type` = 'DEPOSIT'
  AND `created_at` >= '2026-06-01 00:00:00'
  AND `created_at` <  '2026-07-01 00:00:00';

-- 6. Doi chieu ket qua tai chinh tren cung mot snapshot du lieu.
-- NULL-safe equality (<=>) xu ly dung khi ca hai tong deu NULL.
SELECT old_report.`total_deposit` AS `legacy_total`,
       new_report.`total_deposit` AS `optimized_total`,
       old_report.`total_deposit` <=> new_report.`total_deposit` AS `totals_match`
FROM (
    SELECT SUM(`amount`) AS `total_deposit` FROM `Transactions`
    WHERE `transaction_type` = 'DEPOSIT'
      AND YEAR(`created_at`) = 2026 AND MONTH(`created_at`) = 6
) AS old_report
CROSS JOIN (
    SELECT SUM(`amount`) AS `total_deposit` FROM `Transactions`
    WHERE `transaction_type` = 'DEPOSIT'
      AND `created_at` >= '2026-06-01 00:00:00'
      AND `created_at` <  '2026-07-01 00:00:00'
) AS new_report;

-- Tuy chon: EXPLAIN ANALYZE thuc thi truy van, chi dung tren moi truong thu.
-- EXPLAIN ANALYZE
-- SELECT SUM(amount) FROM Transactions
-- WHERE transaction_type = 'DEPOSIT'
--   AND created_at >= '2026-06-01 00:00:00'
--   AND created_at < '2026-07-01 00:00:00';

```

## 2. explain_analysis.md

# Phân tích EXPLAIN trước và sau

| Chỉ số | Legacy chưa có index phù hợp | Truy vấn khoảng có idx_type_date |
|---|---|---|
| type | Dự kiến ALL | Có thể range, tùy thống kê và chi phí |
| key | Không có index phù hợp | Dự kiến idx_type_date nếu được chọn |
| rows | Ước lượng gần tổng số dòng | Ước lượng số dòng trong khoảng cần đọc |

YEAR/MONTH trên created_at không cung cấp khoảng tra cứu trực tiếp cho B-tree thông thường. Index ghép đặt transaction_type trước vì điều kiện bằng, rồi created_at vì điều kiện khoảng. Biên trên loại trừ ngày đầu tháng sau nên giữ đầy đủ tháng 6.

Chưa chạy MySQL, chưa có số rows hoặc ảnh EXPLAIN thực tế. Không khẳng định giảm từ 5 triệu xuống vài nghìn hay đã hết ALL. Bảng nhỏ hoặc điều kiện ít chọn lọc có thể khiến optimizer chọn quét toàn bảng. Sau khi thêm index, truy vấn legacy cũng có thể dùng phần transaction_type, nhưng vẫn lọc tháng bằng hàm.

rows là ước lượng, không phải số dòng thực đo. Cần kiểm tra key, type, rows, thời gian và totals_match trên dữ liệu đại diện trước nghiệm thu.

[Tài liệu MySQL: Range Optimization](https://dev.mysql.com/doc/refman/8.4/en/range-optimization.html).


## 3. ai_prompt_log.md

# Nhật ký sử dụng AI

## Yêu cầu thực tế

Người dùng gửi toàn bộ đề PayFlow trong file đính kèm, trong ngữ cảnh nhờ chuẩn bị bài và đẩy GitHub. AI đọc đề, tra tài liệu MySQL chính thức và viết bản nháp. Không có các lượt hỏi đáp kỹ thuật riêng; các prompt mẫu trong đề không được ghi thành lịch sử thực tế.

## Nội dung đã tìm hiểu và áp dụng

- SARGable: điều kiện có thể được dùng để định vị dữ liệu qua index. Khoảng ngày trực tiếp phù hợp hơn YEAR/MONTH trên cột cho index B-tree thông thường.
- Index ghép (transaction_type, created_at) dùng điều kiện bằng ở cột đầu và khoảng ở cột tiếp theo; thứ tự không chỉ được quyết định bằng độ chọn lọc riêng của từng cột.
- ALL: quét bảng; index: quét index; range: đọc khoảng index; ref: tra theo giá trị khóa không duy nhất; const: tối đa một dòng qua khóa duy nhất phù hợp.
- possible_keys là index có thể dùng; key là index được chọn; rows là ước lượng. Không đồng nhất EXPLAIN với phép đo thời gian thực thi.
- Using index condition là lọc điều kiện ở tầng index trước khi đọc dòng; Using index cho biết truy vấn được đáp ứng bằng index. Index hai cột chưa chứa amount nên chưa phải covering index cho SUM(amount).
- Thứ tự logic giản lược: FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT. Optimizer có thể tổ chức thực thi vật lý khác.
- Quét bảng có thể rẻ hơn tra index khi bảng nhỏ hoặc phải lấy phần lớn dữ liệu. Index bổ sung tăng dung lượng, chi phí ghi và bảo trì.
- SELECT thông thường trên InnoDB không mặc nhiên gây table lock; contention còn phụ thuộc loại giao dịch, isolation, DDL, I/O và tài nguyên. Không kết luận nguyên nhân khóa chỉ từ truy vấn chậm.
- EXPLAIN ANALYZE thực sự chạy truy vấn, nên dùng trên môi trường thử. Không dùng số đo hoặc ảnh giả để chứng minh hiệu năng.

## Tài liệu tham khảo đã tra

- [Range Optimization](https://dev.mysql.com/doc/refman/8.4/en/range-optimization.html)
- [CREATE INDEX](https://dev.mysql.com/doc/refman/8.4/en/create-index.html)
- [Optimization and Indexes](https://dev.mysql.com/doc/refman/8.4/en/optimization-indexes.html)

## Trạng thái kiểm chứng

Đã rà soát tĩnh cú pháp và tính tương đương của khoảng thời gian đối với DATETIME trong schema. Chưa chạy trên MySQL, chưa có bộ dữ liệu 5 triệu dòng, ảnh Console hoặc benchmark. Học viên cần chạy EXPLAIN trước/sau trên dữ liệu đại diện, chụp kết quả và bổ sung số đo thực. Script có truy vấn đối chiếu tổng; kết quả kỳ vọng totals_match = 1 không phải kết quả đã đo.

## Quy tắc dùng AI của đề

Đề giới hạn AI ở việc giải thích, không viết sẵn lời giải tối ưu cuối cùng. Các file này là bản nháp AI tạo ở phạm vi rộng hơn quy tắc đó. Học viên cần tự thực hành, kiểm tra và trao đổi với giảng viên về mức dùng AI trước khi nộp. Nhật ký không tuyên bố đây là bài tự làm.
