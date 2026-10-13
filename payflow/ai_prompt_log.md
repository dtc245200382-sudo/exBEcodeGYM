# Nhật ký sử dụng AI

## Yêu cầu thực tế

Người dùng gửi toàn bộ đề PayFlow trong file đính kèm, trong ngữ cảnh nhờ chuẩn bị bài và đẩy GitHub. AI đọc đề, tra tài liệu MySQL chính thức và viết bản nháp. Không có các lượt hỏi đáp kỹ thuật riêng; các prompt mẫu trong đề không được ghi thành lịch sử thực tế.

## Nội dung đã tìm hiểu và áp dụng

- SARGable: điều kiện có thể được dùng để định vị dữ liệu qua index. Khoảng ngày trực tiếp phù hợp hơn YEAR/MONTH trên cột cho index B-tree thông thường.
- Index ghép (transaction_type, created_at) dùng điều kiện bằng ở cột đầu và khoảng ở cột tiếp theo; thứ tự không chỉ được quyết định bằng độ chọn lọc riêng của từng cột.
- ALL: quét bảng; index: quét index; range: đọc khoảng index; ref: tra theo giá trị khóa không duy nhất; const: tối đa một dòng qua khóa duy nhất phù hợp.
- possible_keys là index có thể dùng; key là index được chọn; rows là ước lượng. Không đồng nhất EXPLAIN với phép đo thời gian thực thi.
- Using index condition là lọc điều kiện ở tầng index trước khi đọc dòng; Using index cho biết truy vấn được đáp ứng bằng index. Index hai cột chưa chứa amount nên chưa phải covering index cho SUM(amount).
- Thứ tự logic giản lược: FROM/JOIN → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT. Optimizer có thể tổ chức thực thi vật lý khác.
- Quét bảng có thể rẻ hơn tra index khi bảng nhỏ hoặc phải lấy phần lớn dữ liệu. Index bổ sung tăng dung lượng, chi phí ghi và bảo trì.
- SELECT thông thường trên InnoDB không mặc nhiên gây table lock; contention còn phụ thuộc loại giao dịch, isolation, DDL, I/O và tài nguyên. Không kết luận nguyên nhân khóa chỉ từ truy vấn chậm.
- EXPLAIN ANALYZE thực sự chạy truy vấn, nên dùng trên môi trường thử. Không dùng số đo hoặc ảnh giả để chứng minh hiệu năng.

## Tài liệu tham khảo đã tra

- [Range Optimization](https://dev.mysql.com/doc/refman/8.4/en/range-optimization.html)
- [CREATE INDEX](https://dev.mysql.com/doc/refman/8.4/en/create-index.html)
- [Optimization and Indexes](https://dev.mysql.com/doc/refman/8.4/en/optimization-indexes.html)

## Trạng thái kiểm chứng

Đã rà soát tĩnh cú pháp và tính tương đương của khoảng thời gian đối với DATETIME trong schema. Chưa chạy trên MySQL, chưa có bộ dữ liệu 5 triệu dòng, ảnh Console hoặc benchmark. Học viên cần chạy EXPLAIN trước/sau trên dữ liệu đại diện, chụp kết quả và bổ sung số đo thực. Script có truy vấn đối chiếu tổng; kết quả kỳ vọng totals_match = 1 không phải kết quả đã đo.

## Quy tắc dùng AI của đề

Đề giới hạn AI ở việc giải thích, không viết sẵn lời giải tối ưu cuối cùng. Các file này là bản nháp AI tạo ở phạm vi rộng hơn quy tắc đó. Học viên cần tự thực hành, kiểm tra và trao đổi với giảng viên về mức dùng AI trước khi nộp. Nhật ký không tuyên bố đây là bài tự làm.
