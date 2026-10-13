# Nhật ký AI thực tế

Người dùng gửi toàn bộ đề MetricsHub qua file đính kèm, trong ngữ cảnh yêu cầu làm bài chung một file và đẩy GitHub. AI đọc đề, tra tài liệu Bootstrap chính thức, tạo HTML/CSS và phần giải trình. Không có lượt hỏi đáp lý thuyết riêng do người dùng đặt; prompt mẫu trong đề không được ghi thành lịch sử thực tế.

## Giải thích đã đưa ra

AI thông báo chọn Flexbox cho navbar, Grid cho Bento và Bootstrap cho bảng giá; thêm nút đổi nhãn tiếng Đức. Bản nháp dùng gap cho cả Flexbox và Grid, wrap cho navbar, minmax(0, 1fr) cho cột Grid để hạn chế tràn nội dung.

Bootstrap Grid dùng Flexbox và các breakpoint dựng sẵn. col-sm-4 bắt đầu chia ba cột từ 576px; col-md-4 bắt đầu từ 768px. Lưới Pricing không có CSS layout riêng; các class Bootstrap xử lý cả chia cột, khoảng cách và chiều cao card.

## Tài liệu đã tra

[Bootstrap 5.3 — Introduction và CDN](https://getbootstrap.com/docs/5.3/getting-started/introduction/).

## Kiểm chứng

Đã rà soát cấu trúc và cú pháp JavaScript. Chưa có trình duyệt kết nối để kiểm tra hiển thị hoặc chụp ảnh ở 375px/768px/1280px. Có media query cho ba mức bố cục và nút đổi nhãn để người học kiểm tra thực tế. Các số liệu dashboard và bảng giá đều là minh hoạ; nút gói chỉ dẫn về dashboard, không mua dịch vụ.

## Phạm vi sử dụng AI

Đề giới hạn AI ở giải thích và boilerplate, không viết lại toàn bộ lời giải. Bản nháp này do AI tạo rộng hơn phạm vi đó. Học viên cần tự kiểm tra, thực hành và trao đổi với giảng viên trước khi nộp; nhật ký không tuyên bố đây là bài tự làm.
