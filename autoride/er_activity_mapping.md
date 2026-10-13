# Đối chiếu Activity Diagram và ERD

Thiết kế cũ thiếu ba nhóm dữ liệu: tiền cọc và phí phát sinh; biên bản kiểm tra xe; trạng thái hợp đồng được kiểm soát. Nhánh “xe hư hỏng” trong Activity Diagram phải có nơi lưu cả mô tả lỗi lẫn số tiền đền bù.

`damage_fee` là bắt buộc vì mô tả “vỡ đèn pha” không đủ để tính tiền hoàn. Lưu khoản phí bằng DECIMAL giúp tính chính xác: cọc 10.000.000 đồng, phạt trễ 0 đồng, sửa chữa 2.000.000 đồng thì hoàn 8.000.000 đồng. Phí cần được lưu theo hợp đồng để đối soát lịch sử, không tính lại theo bảng giá hiện tại.

`Inspections` tách riêng theo quan hệ 1–N, lưu nhiều lần kiểm tra cùng người thực hiện và thời điểm. Khóa ngoại RESTRICT giữ liên kết chứng từ. Trigger chặn kiểm tra khi chưa ACTIVE và yêu cầu biên bản trước khi COMPLETED. ENUM giới hạn tên trạng thái; trigger giới hạn chuyển trạng thái. Nhờ đó, nhánh nghiệp vụ không còn chỉ tồn tại trong ghi chú giấy.
