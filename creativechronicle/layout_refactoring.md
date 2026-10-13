# Phân tích tái cấu trúc layout

Absolute positioning đưa phần tử ra khỏi luồng bình thường. Các ảnh không đóng góp chiều cao cho cha, còn tọa độ và chiều cao cứng khó thích ứng khi màn hình hẹp hoặc nội dung thay đổi. Nội dung phía dưới có thể bị che nếu khoảng trống dự phòng không đủ.

Gallery mới dùng Grid với hai cột 2fr và 1fr. grid-template-areas đặt ảnh chính qua hai hàng; gap tạo khoảng cách thống nhất. Ảnh nhỏ có aspect-ratio, ảnh dùng object-fit để tránh méo. Mobile chuyển thành một cột, ảnh trở lại thứ tự đọc.

Thanh tác giả dùng Flexbox và align-items: center; flex-wrap xử lý tên dài và nhóm nút. Không cần float hoặc clearfix. Bài đề xuất dùng col-12 col-md-6 col-lg-3 của Bootstrap, tự chia một, hai hoặc bốn cột.
