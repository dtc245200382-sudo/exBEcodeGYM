-- Du lieu gia lap de tai lap EXPLAIN, KHONG phai giao dich PayFlow thuc.
-- Chay tren server thu rieng. Script tao schema rieng, khong xoa schema san co.
CREATE DATABASE `payflow_benchmark`;
USE `payflow_benchmark`;
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(15,2),
    transaction_type VARCHAR(20),
    created_at DATETIME
) ENGINE=InnoDB;
CREATE TABLE digits (n INT PRIMARY KEY);
INSERT INTO digits VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
INSERT INTO Transactions (user_id, amount, transaction_type, created_at)
SELECT MOD(seq.n,10000)+1, CAST(MOD(seq.n,100000)+1 AS DECIMAL(15,2)),
       ELT(MOD(seq.n,3)+1,'DEPOSIT','WITHDRAW','TRANSFER'),
       DATE_ADD('2024-01-01 00:00:00', INTERVAL MOD(seq.n,1096) DAY)
FROM (
    SELECT a.n+10*b.n+100*c.n+1000*d.n+10000*e.n+100000*f.n AS n
    FROM digits a CROSS JOIN digits b CROSS JOIN digits c
    CROSS JOIN digits d CROSS JOIN digits e CROSS JOIN digits f
) seq;
ANALYZE TABLE Transactions;
SELECT VERSION() AS mysql_version, COUNT(*) AS fixture_rows FROM Transactions;
SELECT 'BEFORE_INDEX_LEGACY' AS phase;
EXPLAIN SELECT SUM(amount) FROM Transactions
WHERE transaction_type='DEPOSIT' AND YEAR(created_at)=2026 AND MONTH(created_at)=6;
CREATE INDEX idx_type_date ON Transactions(transaction_type,created_at);
ANALYZE TABLE Transactions;
SELECT 'AFTER_INDEX_OPTIMIZED' AS phase;
EXPLAIN SELECT SUM(amount) FROM Transactions
WHERE transaction_type='DEPOSIT'
AND created_at >= '2026-06-01 00:00:00' AND created_at < '2026-07-01 00:00:00';
SELECT 'MEASURED_OPTIMIZED' AS phase;
EXPLAIN ANALYZE SELECT SUM(amount) FROM Transactions
WHERE transaction_type='DEPOSIT'
AND created_at >= '2026-06-01 00:00:00' AND created_at < '2026-07-01 00:00:00';
SELECT old_report.total AS legacy_total, new_report.total AS optimized_total,
       old_report.total <=> new_report.total AS totals_match
FROM (SELECT SUM(amount) AS total FROM Transactions
WHERE transaction_type='DEPOSIT' AND YEAR(created_at)=2026 AND MONTH(created_at)=6) old_report
CROSS JOIN (SELECT SUM(amount) AS total FROM Transactions
WHERE transaction_type='DEPOSIT'
AND created_at >= '2026-06-01 00:00:00' AND created_at < '2026-07-01 00:00:00') new_report;
