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

-- CAC TRUY VAN SELECT THEO YEU CAU
-- Neu da chen du lieu, chi chay phan SELECT duoi day.
-- 1. Hien thi danh sach tat ca hoc vien.
SELECT `StudentID`, `StudentName`, `Address`, `Phone`, `Status` + 0 AS `Status`, `ClassID`
FROM `Student` ORDER BY `StudentID`;

-- 2. Hien thi cac hoc vien dang theo hoc (Status = 1).
SELECT `StudentID`, `StudentName`, `Address`, `Phone`, `Status` + 0 AS `Status`, `ClassID`
FROM `Student`
WHERE `Status` = b'1'
ORDER BY `StudentID`;

-- 3. Hien thi cac mon hoc co thoi gian nho hon 10 gio.
-- Schema chi co Credit; dung Credit < 10 theo yeu cau bai tap.
SELECT `SubID`, `SubName`, `Credit`, `Status` + 0 AS `Status`
FROM `Subject`
WHERE `Credit` < 10
ORDER BY `SubID`;

-- 4. Hien thi cac hoc vien thuoc lop A1.
SELECT s.`StudentID`, s.`StudentName`, s.`Address`, s.`Phone`,
       s.`Status` + 0 AS `Status`, c.`ClassName`
FROM `Student` s
JOIN `Class` c ON c.`ClassID` = s.`ClassID`
WHERE c.`ClassName` = 'A1'
ORDER BY s.`StudentID`;

-- 5. Hien thi diem mon CF cua cac hoc vien.
SELECT s.`StudentID`, s.`StudentName`, sub.`SubName`, m.`Mark`, m.`ExamTimes`
FROM `Student` s
JOIN `Mark` m ON m.`StudentID` = s.`StudentID`
JOIN `Subject` sub ON sub.`SubID` = m.`SubID`
WHERE sub.`SubName` = 'CF'
ORDER BY s.`StudentID`;

-- Ket qua ky vong voi du lieu mau:
-- 1: Hung, Hoa, Manh. 2: Hung, Hoa. 3: CF, C, HDJ.
-- 4: Hung, Hoa. 5: Hung = 8 (lan 1), Hoa = 10 (lan 2).
