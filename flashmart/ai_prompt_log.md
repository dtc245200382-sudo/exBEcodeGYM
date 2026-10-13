# Nhật ký sử dụng AI

## Yêu cầu thực tế

Người dùng gửi toàn bộ đề FlashMart trong file đính kèm, trong ngữ cảnh yêu cầu chuẩn bị bài và đẩy GitHub. AI đọc đề, tạo SQL, phân tích và gói ZIP. Không có lượt hỏi đáp lý thuyết riêng; các prompt gợi ý trong đề không được ghi thành các câu hỏi đã thực sự trao đổi.

## Nội dung AI đã giải thích và áp dụng

- Customers là bảng gốc cho Marketing. LEFT JOIN giữ khách chưa mua; COUNT(order_id) không đếm dòng NULL được bổ sung.
- Products là bảng gốc cho Kho vận. LEFT JOIN và WHERE order_id IS NULL tìm sản phẩm không có giao dịch.
- INNER JOIN chỉ giữ các cặp khớp. RIGHT JOIN giữ Orders nếu không đổi thứ tự bảng nên không giữ được khách chưa có đơn.
- CROSS JOIN tạo tích Descartes; bỏ điều kiện nối hoặc dùng điều kiện luôn đúng có thể làm số dòng tăng mạnh. Hiệu năng phải được đo trên dữ liệu thực, không suy ra chỉ từ tên loại JOIN.
- Hai chỉ mục trên Orders hỗ trợ tra cứu theo customer_id và product_id. Chưa chạy EXPLAIN hoặc benchmark nên không tuyên bố truy vấn đã tối ưu nhất.
- NOT IN có thể cho kết quả ngoài mong muốn khi tập con chứa NULL. NOT EXISTS là lựa chọn khác cho kiểm tra không tồn tại; hiệu năng cần đối chiếu execution plan. Bài nộp dùng anti-join theo đề.

## Kiểm chứng và giới hạn

Đã đối chiếu thủ công dữ liệu mẫu: Marketing có Alice 2, Bob 1, Charlie 0; Kho vận có Keyboard (103). Đây là kết quả kỳ vọng, không phải kết quả chạy MySQL. Chưa có ảnh Result Grid thực tế; học viên cần chạy script và chụp kết quả để hoàn thành bước xác minh.

Script khởi tạo chạy một lần trên schema chưa có các bảng. Mô hình theo đề coi mỗi dòng Orders là một đơn có một sản phẩm; nếu mở rộng một đơn nhiều sản phẩm phải tách bảng chi tiết và rà soát cách đếm.

## Quy tắc AI trong đề

Đề chỉ cho phép AI giải thích và hỗ trợ tìm hiểu, không viết sẵn đáp án cuối cùng. Bản nháp này do AI tạo ở phạm vi rộng hơn quy tắc đó. Học viên cần tự rà soát, thực hành và trao đổi với giảng viên về mức dùng AI trước khi nộp; nhật ký không tuyên bố đây là bài tự làm.
