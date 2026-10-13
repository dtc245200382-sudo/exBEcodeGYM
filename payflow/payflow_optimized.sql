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
