# Vì sao dùng COUNT(o.order_id)?

LEFT JOIN giữ tất cả khách hàng, kể cả khi không có đơn tương ứng. Với Charlie, các cột của Orders được bổ sung NULL. COUNT(*) đếm cả dòng này nên trả về 1, gây sai báo cáo. COUNT(o.order_id) bỏ qua NULL, do đó trả về 0; với Alice và Bob, kết quả lần lượt là 2 và 1.

INNER JOIN chỉ giữ các dòng khớp nên loại Charlie. Báo cáo sản phẩm chưa bán cần LEFT JOIN rồi lọc o.order_id IS NULL. Khóa chính order_id không thể NULL trong dữ liệu thật, vì vậy NULL ở đây chứng tỏ không có đơn tương ứng. INNER JOIN không tạo dòng không khớp nên bộ lọc này không tìm được Keyboard.
