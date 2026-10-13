-- [Thuc hanh] Them du lieu vao CSDL quan ly sinh vien
-- Chay create_database.sql truoc; cac bang can chua co du lieu mau nay.
-- Chi chay script them du lieu mot lan de tranh trung khoa chinh.
USE `QuanLySinhVien`;

START TRANSACTION;

INSERT INTO `Class` (`ClassID`, `ClassName`, `StartDate`, `Status`)
VALUES
    (1, 'A1', '2008-12-20', b'1'),
    (2, 'A2', '2008-12-22', b'1'),
    (3, 'B3', CURRENT_DATE(), b'0');

-- Chi dinh ID de lien ket diem dung voi sinh vien trong de bai.
-- Hoa khong co so dien thoai, luu NULL.
INSERT INTO `Student` (`StudentID`, `StudentName`, `Address`, `Phone`, `Status`, `ClassID`)
VALUES
    (1, 'Hung', 'Ha Noi', '0912113113', b'1', 1),
    (2, 'Hoa', 'Hai phong', NULL, b'1', 1),
    (3, 'Manh', 'HCM', '0123123123', b'0', 2);

INSERT INTO `Subject` (`SubID`, `SubName`, `Credit`, `Status`)
VALUES
    (1, 'CF', 5, b'1'),
    (2, 'C', 6, b'1'),
    (3, 'HDJ', 5, b'1'),
    (4, 'RDBMS', 10, b'1');

-- Giu diem 12 theo de bai; nam trong rang buoc 0-100 cua schema.
INSERT INTO `Mark` (`MarkID`, `SubID`, `StudentID`, `Mark`, `ExamTimes`)
VALUES
    (1, 1, 1, 8, 1),
    (2, 1, 2, 10, 2),
    (3, 2, 1, 12, 1);

COMMIT;

-- Kiem tra du lieu. Chuyen BIT sang so de hien thi de doc.
SELECT `ClassID`, `ClassName`, `StartDate`, `Status` + 0 AS `Status`
FROM `Class` ORDER BY `ClassID`;

SELECT `StudentID`, `StudentName`, `Address`, `Phone`, `Status` + 0 AS `Status`, `ClassID`
FROM `Student` ORDER BY `StudentID`;

SELECT `SubID`, `SubName`, `Credit`, `Status` + 0 AS `Status`
FROM `Subject` ORDER BY `SubID`;

SELECT `MarkID`, `SubID`, `StudentID`, `Mark`, `ExamTimes`
FROM `Mark` ORDER BY `MarkID`;
