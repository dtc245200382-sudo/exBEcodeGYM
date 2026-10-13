# Chiến lược dàn trang MetricsHub

Navbar dùng Flexbox vì các mục được phân bố theo một chiều và độ dài nội dung thay đổi. flex-wrap, min-width và overflow-wrap giúp nhãn tiếng Đức xuống dòng thay vì chồng lên logo.

Dashboard dùng Grid vì cần điều khiển đồng thời hàng và cột. Các widget là con trực tiếp; widget lớn span hai hàng, hai cột. Desktop có ba cột, tablet hai cột, mobile một cột và bỏ span.

Pricing dùng row, col-12 col-md-4, card của Bootstrap: ba cột từ 768px, xếp dọc phía dưới, không viết CSS riêng chia cột. Grid và Flexbox có thể phối hợp: bên trong widget, Flexbox căn biểu tượng cùng chữ. Đây là lựa chọn theo yêu cầu bố cục, không phải quy tắc cấm dùng Grid cho component hoặc Flexbox cho layout.
