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
