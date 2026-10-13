# Nhật ký sử dụng AI

## Yêu cầu thực tế

Người dùng gửi toàn bộ đề AutoRide trong file đính kèm, trong ngữ cảnh nhờ chuẩn bị bài và đẩy GitHub. AI đọc đề và tạo các file SQL, báo cáo, nhật ký. Không có lượt hỏi đáp kỹ thuật riêng về DECIMAL hoặc quan hệ 1–N; không ghi các prompt giả định thành lịch sử thực tế.

## Các quyết định AI đã giải thích / triển khai

- Nâng cấp Rentals bằng ALTER TABLE; kiểm tra trạng thái legacy trước khi đổi sang ENUM. Không xóa bảng cũ.
- DECIMAL(15,2) cho tiền, CHECK không âm. Các khoản tiền legacy chưa biết để NULL; không dùng COALESCE(...,0) vì chưa biết không đồng nghĩa không phát sinh phí.
- Inspections liên kết 1–N với Rentals và dùng ON DELETE RESTRICT; một hợp đồng có thể có nhiều biên bản.
- Trigger chặn INSERT kiểm tra xe ngoài ACTIVE, chặn chuyển trạng thái sai và yêu cầu biên bản trước hoàn tất.
- Kịch bản giả lập tính khoản hoàn 8.000.000 đồng. Kết quả mong đợi không phải bằng chứng đã thực thi.

## Giới hạn cần tự rà soát

- Script migration chạy một lần trên cấu trúc legacy đã cho. DDL không được rollback cùng DML; nếu lỗi, cần dừng và kiểm tra trước khi tiếp tục. Không chạy lại cả file sau migration thành công.
- Cần MySQL hỗ trợ CHECK thực sự. Chưa chạy thử trong MySQL, chưa có log hoặc ảnh kết quả truy vấn.
- Chưa có ngày hẹn trả hay biểu phí trễ nên late_fee được nhập theo kịch bản, không tự suy ra từ return_date. Ví dụ bổ sung trả trễ hai ngày cần chính sách tính phí do người dùng xác định.
- Refund là số tiền cần hoàn, chưa phải chứng từ đã chi trả. Nếu tổng phí vượt cọc, truy vấn tách số tiền cần thu thêm.
- Dữ liệu hợp đồng cũ cần đối chiếu và bổ sung; các trạng thái COMPLETED cũ không tự được tạo biên bản giả. Thiết kế không bao gồm phân quyền, nhật ký chỉnh sửa hay kiểm soát trùng lịch thuê xe.

## Quy tắc AI của bài tập

Đề giới hạn AI ở việc giải thích và phản biện, không viết toàn bộ bài thay học viên. Các file này là bản nháp do AI tạo với phạm vi rộng hơn quy tắc đó. Học viên cần tự kiểm tra, thực hành và trao đổi với giảng viên về mức dùng AI trước khi nộp. Nhật ký không tuyên bố đây là bài tự làm.
