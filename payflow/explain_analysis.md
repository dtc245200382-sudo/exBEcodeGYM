# Phân tích EXPLAIN trước và sau

| Chỉ số | Legacy trước index | Truy vấn khoảng sau index |
|---|---|---|
| type | ALL | range |
| key | NULL | idx_type_date |
| rows | 997290 | 16908 |

YEAR/MONTH trên created_at không cung cấp khoảng tra cứu trực tiếp cho B-tree thông thường. Index ghép đặt transaction_type trước vì điều kiện bằng, rồi created_at vì điều kiện khoảng. Biên trên loại trừ ngày đầu tháng sau nên giữ đầy đủ tháng 6.

Đã chạy MySQL 8.4.11 trên server thử riêng với 1.000.000 dòng giả lập, không phải 5 triệu giao dịch PayFlow thực tế. Log nguyên bản: explain_console.txt; script tái lập: benchmark_fixture.sql. possible_keys sau tối ưu là idx_type_date; Extra là Using index condition. EXPLAIN ANALYZE đọc thực tế 9120 dòng, tổng hợp khoảng 26,6 ms trong lần chạy này. Chưa đo thời gian truy vấn cũ nên không tính hệ số tăng tốc.

rows là ước lượng. Hai tổng đều 456144560.00, totals_match = 1. Kế hoạch trên dữ liệu sản xuất có thể khác; cần đo lại trước nghiệm thu.

[Tài liệu MySQL: Range Optimization](https://dev.mysql.com/doc/refman/8.4/en/range-optimization.html).
