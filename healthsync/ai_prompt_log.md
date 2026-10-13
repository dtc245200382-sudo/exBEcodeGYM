# Nhật ký sử dụng AI

## Nội dung thực tế của phiên làm việc

Người dùng gửi toàn bộ đề HealthSync trong file đính kèm, trong ngữ cảnh yêu cầu làm bài và đẩy lên GitHub. AI đọc đề, tạo bản nháp SQL, báo cáo và nhật ký này. Không có các lượt hỏi đáp riêng về ENUM, DECIMAL hay ALTER TABLE; không ghi lại những prompt mẫu như thể chúng đã được dùng.

## Quyết định trong bản nháp

- Dùng ENUM cho năm trạng thái, bổ sung bước CONFIRMED trước CHECKED_IN trong kịch bản thành công.
- Dùng DECIMAL cho tiền; thêm CHECK cho giới hạn phí phạt và lý do hủy.
- Chọn quan hệ một lịch hẹn tối đa một đơn thuốc, dùng UNIQUE và khóa ngoại RESTRICT.
- Thêm trigger INSERT/UPDATE đơn thuốc, kiểm tra lịch COMPLETED; trigger lịch hẹn chặn chuyển ngược từ trạng thái kết thúc.
- Chọn tạo schema mới để không đoán trạng thái hoặc xóa dữ liệu legacy.

## Đối chiếu quy tắc của bài

Đề giới hạn AI ở vai trò gợi ý và phản biện, không viết toàn bộ lời giải thay học viên. Bản nháp này được AI tạo ở phạm vi rộng hơn quy tắc đó. Học viên cần tự rà soát, thực hành, điều chỉnh và trao đổi với giảng viên về mức sử dụng AI trước khi nộp; nhật ký không thể hiện đây là bài tự làm.

## Kiểm chứng

Chưa có phiên MySQL chạy thử, ảnh kết quả hoặc lỗi thực thi thực tế. Các lệnh thử âm tính có trong SQL dưới dạng chú thích để học viên chạy riêng. Không có bằng chứng thực nghiệm về trigger hoặc CHECK trong môi trường của học viên.
