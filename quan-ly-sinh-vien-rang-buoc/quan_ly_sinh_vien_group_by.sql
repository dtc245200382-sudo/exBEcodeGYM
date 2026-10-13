-- [Thực hành] Sử dụng các hàm thông dụng trong SQL
-- Một file chứa đầy đủ 4 yêu cầu; dùng CSDL và dữ liệu từ bài trước.
USE `QuanLySinhVien`;

-- 1. Hiển thị số lượng sinh viên ở từng nơi.
SELECT `Address`, COUNT(`StudentID`) AS `SoLuongHocVien`
FROM `Student`
GROUP BY `Address`
ORDER BY `Address`;

-- 2. Tính điểm trung bình các môn học của mỗi học viên có điểm.
SELECT s.`StudentID`, s.`StudentName`, AVG(m.`Mark`) AS `DiemTrungBinh`
FROM `Student` AS s
JOIN `Mark` AS m ON m.`StudentID` = s.`StudentID`
GROUP BY s.`StudentID`, s.`StudentName`
ORDER BY s.`StudentID`;

-- 3. Hiển thị học viên có điểm trung bình lớn hơn 15.
SELECT s.`StudentID`, s.`StudentName`, AVG(m.`Mark`) AS `DiemTrungBinh`
FROM `Student` AS s
JOIN `Mark` AS m ON m.`StudentID` = s.`StudentID`
GROUP BY s.`StudentID`, s.`StudentName`
HAVING AVG(m.`Mark`) > 15
ORDER BY s.`StudentID`;

-- 4. Hiển thị thông tin tất cả học viên có điểm trung bình lớn nhất.
-- Không dùng LIMIT 1 vì có thể có nhiều học viên đồng hạng.
-- Loại nhóm chưa có điểm khỏi truy vấn con để NULL không ảnh hưởng ALL.
SELECT s.`StudentID`, s.`StudentName`, s.`Address`, s.`Phone`,
       s.`Status` + 0 AS `Status`, s.`ClassID`,
       AVG(m.`Mark`) AS `DiemTrungBinh`
FROM `Student` AS s
JOIN `Mark` AS m ON m.`StudentID` = s.`StudentID`
GROUP BY s.`StudentID`, s.`StudentName`, s.`Address`, s.`Phone`,
         s.`Status`, s.`ClassID`
HAVING AVG(m.`Mark`) >= ALL (
    SELECT AVG(m2.`Mark`)
    FROM `Mark` AS m2
    JOIN `Student` AS s2 ON s2.`StudentID` = m2.`StudentID`
    GROUP BY m2.`StudentID`
    HAVING AVG(m2.`Mark`) IS NOT NULL
)
ORDER BY s.`StudentID`;

-- Với dữ liệu mẫu bài trước:
-- 1: Ha Noi = 1, Hai phong = 1, HCM = 1.
-- 2: Hung = 10, Hoa = 10; Manh chưa có điểm nên không thuộc nhóm có điểm.
-- 3: Không có học viên có điểm trung bình > 15.
-- 4: Hung và Hoa cùng có điểm trung bình cao nhất là 10.
