# Phân tích tính nhất quán HealthSync

Thiết kế cũ có ba điểm vênh nghiêm trọng. Thứ nhất, `is_active` chỉ biểu diễn hai giá trị, không phân biệt chờ duyệt, xác nhận cọc, đã đến, hoàn tất và đã hủy. Thay bằng `status` ENUM và trigger kiểm soát chuyển trạng thái giúp dữ liệu phản ánh vòng đời nghiệp vụ.

Thứ hai, thiếu tiền cọc, phí phạt và lý do hủy khiến hệ thống không thể đối soát trường hợp hủy sau xác nhận. `deposit_amount`, `penalty_fee` dùng DECIMAL để tránh sai số biểu diễn số thực. CHECK bảo đảm tiền cọc không âm, phí phạt không vượt cọc; lịch hủy phải có lý do. Phí phạt cần được lưu vì chính sách có thể thay đổi; tính lại theo chính sách hiện tại có thể làm sai báo cáo lịch sử. Tiền cọc còn lại không đồng nghĩa đã hoàn tiền.

Thứ ba, thiếu bảng đơn thuốc. `Prescriptions` dùng khóa ngoại và UNIQUE để mỗi lịch hẹn có tối đa một đơn. Trigger chặn thêm hoặc chuyển đơn sang lịch chưa COMPLETED. RESTRICT giữ dữ liệu liên quan khi xóa lịch hẹn.

## Phạm vi và xác minh

- File SQL là phương án tạo schema mới; không chạy trực tiếp lên schema đã có bảng legacy và không tự xóa dữ liệu cũ. Boolean cũ không đủ để suy ra trạng thái thật; migration cần đối chiếu hồ sơ trước khi bỏ cột.
- Mô hình: Patients 1–N Appointments; Doctors 1–N Appointments; Appointments 1–0..1 Prescriptions. Khi hoàn tất, ứng dụng cần cập nhật trạng thái và thêm đơn trong cùng giao dịch. Trigger chỉ bảo đảm đơn thuộc lịch hoàn tất, không bắt buộc mọi lịch hoàn tất đã có đơn.
- ENUM không chứng minh đã nhận cọc thực tế. Bài này lưu số tiền theo kịch bản, chưa có sổ giao dịch thanh toán hoặc lịch sử thay đổi.
- Đã rà soát tĩnh và đẩy GitHub; chưa chạy SQL trên MySQL. Các kết quả trong chú thích là kỳ vọng, không phải kết quả thực thi.
