-- [Bài tập] Truy vấn dữ liệu với CSDL Quản lý sinh viên
-- Sử dụng cấu trúc và dữ liệu đã tạo ở các bài trước.
USE `QuanLySinhVien`;

-- 1. Hiển thị tất cả sinh viên có tên bắt đầu bằng ký tự 'h'.
-- LOWER giúp tìm cả tên bắt đầu bằng H và h.
SELECT `StudentID`, `StudentName`, `Address`, `Phone`,
       `Status` + 0 AS `Status`, `ClassID`
FROM `Student`
WHERE LOWER(`StudentName`) LIKE 'h%'
ORDER BY `StudentID`;

-- 2. Hiển thị thông tin lớp học bắt đầu vào tháng 12, không giới hạn năm.
SELECT `ClassID`, `ClassName`, `StartDate`, `Status` + 0 AS `Status`
FROM `Class`
WHERE MONTH(`StartDate`) = 12
ORDER BY `ClassID`;

-- 3. Hiển thị môn học có Credit trong khoảng 3 đến 5, gồm cả hai đầu mút.
SELECT `SubID`, `SubName`, `Credit`, `Status` + 0 AS `Status`
FROM `Subject`
WHERE `Credit` BETWEEN 3 AND 5
ORDER BY `SubID`;

-- 4. Thay đổi mã lớp của sinh viên tên Hung thành 2.
UPDATE `Student`
SET `ClassID` = 2
WHERE `StudentName` = 'Hung';

-- 5. Hiển thị tên sinh viên, tên môn học, điểm thi.
-- Điểm giảm dần; nếu điểm trùng nhau thì tên sinh viên tăng dần.
SELECT s.`StudentName`, sub.`SubName`, m.`Mark`
FROM `Student` AS s
JOIN `Mark` AS m ON m.`StudentID` = s.`StudentID`
JOIN `Subject` AS sub ON sub.`SubID` = m.`SubID`
ORDER BY m.`Mark` DESC, s.`StudentName` ASC;
