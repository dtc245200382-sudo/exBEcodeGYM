-- AutoRide: chay mot lan tren schema legacy hoac schema moi.
-- Khong DROP bang/CSDL. Sao luu va doi chieu du lieu truoc khi migration.
CREATE DATABASE IF NOT EXISTS `autoride_db`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `autoride_db`;

-- Khoi tao dung cau truc legacy neu chua co.
CREATE TABLE IF NOT EXISTS `Cars` (
    `car_id` INT AUTO_INCREMENT PRIMARY KEY,
    `model_name` VARCHAR(100) NOT NULL,
    `license_plate` VARCHAR(20) UNIQUE NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `Rentals` (
    `rental_id` INT AUTO_INCREMENT PRIMARY KEY,
    `car_id` INT,
    `customer_name` VARCHAR(100) NOT NULL,
    `rent_date` DATETIME NOT NULL,
    `return_date` DATETIME,
    `status` VARCHAR(50) DEFAULT 'BOOKED',
    FOREIGN KEY (`car_id`) REFERENCES `Cars` (`car_id`)
) ENGINE=InnoDB;

DELIMITER $$
-- Dung migration neu trang thai cu khong chuyen duoc sang ENUM.
-- Khong tu doan trang thai thay cho nguoi van hanh.
CREATE PROCEDURE `migrate_autoride`()
BEGIN
    IF EXISTS (SELECT 1 FROM Rentals WHERE status IS NULL OR
        BINARY status NOT IN ('BOOKED','ACTIVE','COMPLETED','CANCELLED')) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Review invalid legacy statuses before migration';
    ELSE
        ALTER TABLE Rentals
            MODIFY COLUMN status ENUM('BOOKED','ACTIVE','COMPLETED','CANCELLED')
                NOT NULL DEFAULT 'BOOKED',
            ADD COLUMN security_deposit DECIMAL(15,2) NULL DEFAULT NULL,
            ADD COLUMN late_fee DECIMAL(15,2) NULL DEFAULT NULL,
            ADD COLUMN damage_fee DECIMAL(15,2) NULL DEFAULT NULL,
            ADD CONSTRAINT CHK_Rentals_Deposit CHECK (security_deposit >= 0),
            ADD CONSTRAINT CHK_Rentals_LateFee CHECK (late_fee >= 0),
            ADD CONSTRAINT CHK_Rentals_DamageFee CHECK (damage_fee >= 0);
    END IF;
END$$
DELIMITER ;
CALL `migrate_autoride`();
DROP PROCEDURE `migrate_autoride`;

-- Quan he 1-N: mot hop dong co the co nhieu bien ban kiem tra.
CREATE TABLE `Inspections` (
    `inspection_id` INT AUTO_INCREMENT PRIMARY KEY,
    `rental_id` INT NOT NULL,
    `inspection_date` DATETIME NOT NULL,
    `damage_description` TEXT NOT NULL,
    `inspector_name` VARCHAR(100) NOT NULL,
    CONSTRAINT `FK_Inspections_Rentals` FOREIGN KEY (`rental_id`)
        REFERENCES `Rentals` (`rental_id`) ON DELETE RESTRICT,
    CONSTRAINT `CHK_Inspection_Inspector` CHECK (CHAR_LENGTH(TRIM(`inspector_name`)) > 0),
    CONSTRAINT `CHK_Inspection_Description` CHECK (CHAR_LENGTH(TRIM(`damage_description`)) > 0)
) ENGINE=InnoDB;

DELIMITER $$
CREATE TRIGGER `trg_inspection_insert`
BEFORE INSERT ON `Inspections` FOR EACH ROW
BEGIN
    DECLARE rental_status VARCHAR(20) DEFAULT NULL;
    DECLARE rental_start DATETIME;
    SELECT status, rent_date INTO rental_status, rental_start
    FROM Rentals WHERE rental_id = NEW.rental_id FOR UPDATE;
    IF rental_status IS NULL OR rental_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inspection requires an ACTIVE rental';
    END IF;
    IF NEW.inspection_date < rental_start THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inspection cannot precede rental start';
    END IF;
END$$

CREATE TRIGGER `trg_inspection_update`
BEFORE UPDATE ON `Inspections` FOR EACH ROW
BEGIN
    DECLARE rental_status VARCHAR(20) DEFAULT NULL;
    SELECT status INTO rental_status FROM Rentals
    WHERE rental_id = OLD.rental_id FOR UPDATE;
    IF NEW.rental_id <> OLD.rental_id OR rental_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot move inspection or edit a closed rental inspection';
    END IF;
    IF NEW.inspection_date < (SELECT rent_date FROM Rentals WHERE rental_id = OLD.rental_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Inspection cannot precede rental start';
    END IF;
END$$

CREATE TRIGGER `trg_rental_update`
BEFORE UPDATE ON `Rentals` FOR EACH ROW
BEGIN
    IF NEW.status <> OLD.status AND NOT (
        (OLD.status = 'BOOKED' AND NEW.status IN ('ACTIVE','CANCELLED')) OR
        (OLD.status = 'ACTIVE' AND NEW.status = 'COMPLETED')
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid rental status transition';
    END IF;
    IF NEW.status = 'COMPLETED' THEN
        IF NEW.security_deposit IS NULL OR NEW.late_fee IS NULL OR NEW.damage_fee IS NULL
            OR NEW.return_date IS NULL OR NEW.return_date < NEW.rent_date THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Completion requires known amounts and valid return date';
        END IF;
        IF NOT EXISTS (SELECT 1 FROM Inspections WHERE rental_id = OLD.rental_id
            AND inspection_date BETWEEN NEW.rent_date AND NEW.return_date) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Completion requires a return inspection';
        END IF;
    END IF;
END$$

CREATE TRIGGER `trg_rental_insert`
BEFORE INSERT ON `Rentals` FOR EACH ROW
BEGIN
    IF NEW.status NOT IN ('BOOKED','ACTIVE') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New rental must be BOOKED or ACTIVE';
    END IF;
    IF NEW.car_id IS NULL OR NEW.security_deposit IS NULL OR NEW.security_deposit <= 0
        OR NEW.late_fee IS NULL OR NEW.damage_fee IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'New rental requires car, deposit and explicit fees';
    END IF;
END$$
DELIMITER ;

START TRANSACTION;
INSERT INTO `Cars` (`model_name`, `license_plate`) VALUES ('Toyota Vios', '30A-12345');
SET @car_id = LAST_INSERT_ID();
INSERT INTO `Rentals` (`car_id`, `customer_name`, `rent_date`, `status`,
    `security_deposit`, `late_fee`, `damage_fee`)
VALUES (@car_id, 'Nguyen Van A', '2026-10-15 08:00:00', 'BOOKED', 10000000, 0, 0);
SET @rental_id = LAST_INSERT_ID();
UPDATE `Rentals` SET `status` = 'ACTIVE' WHERE `rental_id` = @rental_id;

INSERT INTO `Inspections` (`rental_id`, `inspection_date`, `damage_description`, `inspector_name`)
VALUES (@rental_id, '2026-10-17 08:00:00', 'Vỡ đèn pha trái', 'Tran Van B');
UPDATE `Rentals`
SET `status` = 'COMPLETED', `return_date` = '2026-10-17 08:00:00',
    `late_fee` = 0, `damage_fee` = 2000000
WHERE `rental_id` = @rental_id;
COMMIT;

-- Ket qua ky vong: 10000000 - 0 - 2000000 = 8000000 VND.
-- Gia tri NULL cua hop dong cu khong bi bien thanh 0 bang COALESCE.
SELECT rental_id, customer_name, status, security_deposit, late_fee, damage_fee,
       security_deposit - late_fee - damage_fee AS net_deposit_balance,
       GREATEST(security_deposit - late_fee - damage_fee, 0) AS refund_amount,
       GREATEST(late_fee + damage_fee - security_deposit, 0) AS additional_amount_due
FROM Rentals WHERE rental_id = @rental_id;

SELECT r.rental_id, r.customer_name, i.inspection_date, i.damage_description, i.inspector_name
FROM Rentals r JOIN Inspections i ON i.rental_id = r.rental_id
WHERE r.rental_id = @rental_id;

-- Thu rieng: doi trang thai COMPLETED ve BOOKED phai bi trigger tu choi.
-- UPDATE Rentals SET status = 'BOOKED' WHERE rental_id = @rental_id;
-- Xoa hop dong dang co bien ban phai bi FK RESTRICT tu choi.
-- DELETE FROM Rentals WHERE rental_id = @rental_id;

-- Thu rieng tren giao dich thu nghiem: bien ban cua BOOKED phai bi tu choi.
-- START TRANSACTION;
-- INSERT INTO Rentals (car_id, customer_name, rent_date, security_deposit, late_fee, damage_fee)
-- VALUES (@car_id, 'Test BOOKED', '2026-10-20 08:00:00', 10000000, 0, 0);
-- SET @booked_rental = LAST_INSERT_ID();
-- INSERT INTO Inspections (rental_id, inspection_date, damage_description, inspector_name)
-- VALUES (@booked_rental, '2026-10-20 09:00:00', 'Du lieu thu', 'Tester');
-- ROLLBACK;
