# Nhật ký AI

## Yêu cầu thực tế

Người dùng gửi toàn bộ đề CreativeChronicle trong file đính kèm, trong ngữ cảnh nhờ làm bài và push GitHub với một file nộp chung. AI đọc đề, tạo giao diện mẫu và giải trình. Không có các câu hỏi kỹ thuật độc lập do người dùng đặt; không ghi prompt gợi ý thành hỏi đáp đã xảy ra.

## Nội dung đã giải thích và áp dụng

- Author Info dùng Flexbox, align-items: center, justify-content: space-between, flex-wrap và gap. Cụm avatar/tên là flex-container riêng; phần chữ min-width: 0 và overflow-wrap để chịu tên dài.
- Gallery dùng Grid hai chiều, grid-template-areas và tỷ lệ 2fr/1fr. Không có float hoặc position: absolute trong CSS của bài. Các ảnh và widget vẫn tham gia luồng, không che nội dung phía dưới do tọa độ cứng.
- Float phục vụ chữ bao quanh phần tử; nếu cha chỉ có con float và không tạo cơ chế chứa float, chiều cao tự động có thể không bao con. Flexbox bố trí con trực tiếp và hỗ trợ căn chỉnh dọc.
- Thêm ảnh thứ tư/năm vào Grid mà không đặt area cụ thể sẽ tạo phần tử auto-placement; Grid có thể thêm hàng ngầm. Cần rà soát thứ tự và kích thước nếu thay đổi thiết kế. Bản bài tập giữ đúng ba ảnh.
- Bootstrap dùng row g-4, col-12 col-md-6 col-lg-3, card h-100 và các utility d-flex, align-items-center, gap-2, mb-4. col-md từ 768px, col-lg từ 992px.
- Các minh hoạ là SVG tạo bằng mã, nhúng trong HTML để không cần tải ảnh bên ngoài. Văn bản và tác giả đều là nội dung mẫu.

## Kiểm chứng

Đã kiểm tra cú pháp JavaScript và rà soát không có float/absolute trong CSS tự viết. Chưa có trình duyệt kết nối nên chưa chạy stress test trực quan ở 1200px, 768px hoặc 375px. Nút “Thử tên dài” hỗ trợ học viên kiểm tra; cần tự chụp ảnh và xác minh bố cục trước khi nộp. CDN Bootstrap cần kết nối mạng.

## Quy tắc AI của đề

Đề giới hạn AI ở tìm hiểu và hỗ trợ, không sửa toàn bộ bài thay học viên. Đây là bản nháp do AI tạo rộng hơn phạm vi đó; cần tự rà soát, thực hành và trao đổi với giảng viên trước khi nộp. Nhật ký không tuyên bố đây là bài tự làm.
