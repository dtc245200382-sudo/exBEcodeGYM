-- HealthSync: schema moi va hai kich ban minh hoa.
-- Chay tren schema healthsync_db chua co cac bang nay.
-- Khong DROP bang/CSDL cu. Neu da co du lieu legacy, can migration rieng.
CREATE DATABASE IF NOT EXISTS `healthsync_db`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `healthsync_db`;

CREATE TABLE `Patients` (
    `patient_id` INT AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(100) NOT NULL,
    `phone` VARCHAR(15) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE `Doctors` (
    `doctor_id` INT AUTO_INCREMENT PRIMARY KEY,
    `full_name` VARCHAR(100) NOT NULL,
    `specialty` VARCHAR(50)
) ENGINE=InnoDB;

CREATE TABLE `Appointments` (
    `appointment_id` INT AUTO_INCREMENT PRIMARY KEY,
    `patient_id` INT NOT NULL,
    `doctor_id` INT NOT NULL,
    `appointment_date` DATETIME NOT NULL,
    `status` ENUM('PENDING','CONFIRMED','CHECKED_IN','COMPLETED','CANCELLED')
        NOT NULL DEFAULT 'PENDING',
    `deposit_amount` DECIMAL(15,2) NOT NULL DEFAULT 0,
    `penalty_fee` DECIMAL(15,2) NOT NULL DEFAULT 0,
    `cancel_reason` VARCHAR(255),
    CONSTRAINT `FK_Appointments_Patients` FOREIGN KEY (`patient_id`)
        REFERENCES `Patients` (`patient_id`) ON DELETE RESTRICT,
    CONSTRAINT `FK_Appointments_Doctors` FOREIGN KEY (`doctor_id`)
        REFERENCES `Doctors` (`doctor_id`) ON DELETE RESTRICT,
    CONSTRAINT `CHK_Deposit` CHECK (`deposit_amount` >= 0),
    CONSTRAINT `CHK_Penalty` CHECK (`penalty_fee` BETWEEN 0 AND `deposit_amount`),
    CONSTRAINT `CHK_Cancellation` CHECK (
        (`status` = 'CANCELLED' AND `cancel_reason` IS NOT NULL
            AND CHAR_LENGTH(TRIM(`cancel_reason`)) > 0)
        OR (`status` <> 'CANCELLED' AND `cancel_reason` IS NULL AND `penalty_fee` = 0)
    )
) ENGINE=InnoDB;

CREATE TABLE `Prescriptions` (
    `prescription_id` INT AUTO_INCREMENT PRIMARY KEY,
    `appointment_id` INT NOT NULL,
    `medication_details` TEXT NOT NULL,
    `issued_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `UQ_Prescriptions_Appointment` UNIQUE (`appointment_id`),
    CONSTRAINT `FK_Prescriptions_Appointments` FOREIGN KEY (`appointment_id`)
        REFERENCES `Appointments` (`appointment_id`) ON DELETE RESTRICT,
    CONSTRAINT `CHK_Medication_Details`
        CHECK (CHAR_LENGTH(TRIM(`medication_details`)) > 0)
) ENGINE=InnoDB;

DELIMITER $$

-- Chi cho phep cac buoc chuyen trang thai hop le.
CREATE TRIGGER `trg_appointment_transition`
BEFORE UPDATE ON `Appointments`
FOR EACH ROW
BEGIN
    IF NEW.status <> OLD.status AND NOT (
        (OLD.status = 'PENDING' AND NEW.status IN ('CONFIRMED','CANCELLED')) OR
        (OLD.status = 'CONFIRMED' AND NEW.status IN ('CHECKED_IN','CANCELLED')) OR
        (OLD.status = 'CHECKED_IN' AND NEW.status IN ('COMPLETED','CANCELLED'))
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid appointment status transition';
    END IF;
END$$

-- FK chi kiem tra lich hen ton tai; trigger kiem tra dieu kien nghiep vu.
CREATE TRIGGER `trg_prescription_insert`
BEFORE INSERT ON `Prescriptions`
FOR EACH ROW
BEGIN
    DECLARE appointment_status VARCHAR(20) DEFAULT NULL;
    SELECT status INTO appointment_status FROM Appointments
    WHERE appointment_id = NEW.appointment_id FOR UPDATE;
    IF appointment_status IS NULL OR appointment_status <> 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prescription requires a COMPLETED appointment';
    END IF;
END$$

CREATE TRIGGER `trg_prescription_update`
BEFORE UPDATE ON `Prescriptions`
FOR EACH ROW
BEGIN
    DECLARE appointment_status VARCHAR(20) DEFAULT NULL;
    SELECT status INTO appointment_status FROM Appointments
    WHERE appointment_id = NEW.appointment_id FOR UPDATE;
    IF appointment_status IS NULL OR appointment_status <> 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Prescription requires a COMPLETED appointment';
    END IF;
END$$
DELIMITER ;

START TRANSACTION;
INSERT INTO `Patients` (`full_name`, `phone`) VALUES ('Nguyễn Văn A', '0900000001');
SET @patient_a = LAST_INSERT_ID();
INSERT INTO `Patients` (`full_name`, `phone`) VALUES ('Trần Thị B', '0900000002');
SET @patient_b = LAST_INSERT_ID();
INSERT INTO `Doctors` (`full_name`, `specialty`) VALUES ('Lê Minh C', 'Nội tổng quát');
SET @doctor = LAST_INSERT_ID();

-- Kich ban 1: di qua CONFIRMED de khop vong doi trong mo ta.
INSERT INTO `Appointments` (`patient_id`, `doctor_id`, `appointment_date`, `deposit_amount`)
VALUES (@patient_a, @doctor, '2026-10-15 09:00:00', 500000);
SET @successful_appointment = LAST_INSERT_ID();
UPDATE `Appointments` SET `status` = 'CONFIRMED' WHERE `appointment_id` = @successful_appointment;
UPDATE `Appointments` SET `status` = 'CHECKED_IN' WHERE `appointment_id` = @successful_appointment;
UPDATE `Appointments` SET `status` = 'COMPLETED' WHERE `appointment_id` = @successful_appointment;
INSERT INTO `Prescriptions` (`appointment_id`, `medication_details`, `issued_date`)
VALUES (@successful_appointment, 'Đơn thuốc giả lập phục vụ bài tập, không dùng điều trị.', '2026-10-15 09:30:00');

-- Kich ban 2: muc phat 150000 la du lieu theo de, khong phai chinh sach chung.
INSERT INTO `Appointments` (`patient_id`, `doctor_id`, `appointment_date`, `status`, `deposit_amount`)
VALUES (@patient_b, @doctor, '2026-10-16 10:00:00', 'CONFIRMED', 300000);
SET @cancelled_appointment = LAST_INSERT_ID();
UPDATE `Appointments`
SET `status` = 'CANCELLED', `cancel_reason` = 'Bận việc đột xuất', `penalty_fee` = 150000
WHERE `appointment_id` = @cancelled_appointment;
COMMIT;

-- Ket qua mong doi: A COMPLETED, coc 500000, phat 0;
-- B CANCELLED, coc 300000, phat 150000, so tien con lai 150000.
-- So tien con lai la gia tri tinh toan, khong chung minh da hoan tien.
SELECT a.appointment_id, p.full_name, a.status, a.deposit_amount,
       a.penalty_fee, a.deposit_amount - a.penalty_fee AS remaining_deposit,
       a.cancel_reason
FROM Appointments a JOIN Patients p ON p.patient_id = a.patient_id
ORDER BY a.appointment_id;

SELECT a.appointment_id, p.full_name AS patient_name, d.full_name AS doctor_name,
       pr.medication_details, pr.issued_date
FROM Appointments a
JOIN Patients p ON p.patient_id = a.patient_id
JOIN Doctors d ON d.doctor_id = a.doctor_id
JOIN Prescriptions pr ON pr.appointment_id = a.appointment_id
WHERE a.status = 'COMPLETED';

-- Thu rieng cac lenh am tinh nay: phai bi tu choi (khong bo comment de chay toan file).
-- INSERT INTO Appointments (patient_id, doctor_id, appointment_date)
-- VALUES (@patient_a, @doctor, '2026-10-17 09:00:00');
-- SET @pending_appointment = LAST_INSERT_ID();
-- INSERT INTO Prescriptions (appointment_id, medication_details)
-- VALUES (@pending_appointment, 'Du lieu thu: phai bi trigger chan');
-- UPDATE Appointments SET penalty_fee = 400000 WHERE appointment_id = @cancelled_appointment;
-- UPDATE Appointments SET status = 'PENDING' WHERE appointment_id = @successful_appointment;
