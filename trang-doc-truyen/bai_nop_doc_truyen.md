# Bài tập: Tạo trang đọc truyện ngắn

Bài nộp chung gồm toàn bộ HTML và CSS. Để chạy, tải index.html và styles.css về cùng thư mục, rồi mở index.html trong trình duyệt.

Trang có ảnh minh hoạ SVG ở đầu, 3 mục lục bằng thẻ h5, liên kết đến từng truyện, liên kết trở về mục lục, CSS ngoài và bố cục co giãn trên điện thoại.

## index.html

```html
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Góc truyện nhỏ</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <main>
        <header class="page-header">
            <svg class="cover" viewBox="0 0 960 300" role="img" aria-labelledby="cover-title cover-description">
                <title id="cover-title">Cuốn sách dưới bầu trời đêm</title>
                <desc id="cover-description">Ảnh minh hoạ những ngọn đồi, mặt trăng và cuốn sách đang mở.</desc>
                <rect width="960" height="300" fill="#233e45"/>
                <circle cx="770" cy="65" r="31" fill="#f5dfad"/>
                <g fill="#f5dfad">
                    <circle cx="110" cy="45" r="2"/><circle cx="300" cy="60" r="3"/>
                    <circle cx="555" cy="35" r="2"/><circle cx="640" cy="90" r="2"/>
                    <circle cx="880" cy="120" r="3"/><circle cx="430" cy="100" r="2"/>
                </g>
                <path d="M0 220 Q130 105 270 215 T540 200 T800 180 T960 200 V300 H0Z" fill="#406267"/>
                <path d="M0 255 Q190 180 370 245 T720 235 T960 240 V300 H0Z" fill="#547b70"/>
                <path d="M320 180 Q410 155 480 195 Q550 155 640 180 V255 Q550 230 480 265 Q410 230 320 255Z" fill="#caaa76"/>
                <path d="M330 167 Q405 147 480 183 V250 Q405 218 330 239Z" fill="#fff5df"/>
                <path d="M480 183 Q555 147 630 167 V239 Q555 218 480 250Z" fill="#f3e5c5"/>
                <g fill="none" stroke="#baa584" stroke-width="2">
                    <path d="M350 183 Q412 169 463 192 M350 199 Q412 185 463 208 M350 215 Q412 201 463 224"/>
                    <path d="M497 192 Q549 169 610 183 M497 208 Q549 185 610 199 M497 224 Q549 201 610 215"/>
                </g>
            </svg>
            <p class="eyebrow">Mỗi ngày một câu chuyện</p>
            <h1>Góc truyện nhỏ</h1>
            <p class="intro">Ba câu chuyện ngắn về những điều bình dị quanh ta.</p>
        </header>

        <nav class="contents" id="muc-luc" aria-labelledby="contents-title">
            <h2 id="contents-title">Mục lục truyện</h2>
            <h5><a href="#chiec-o-mau-vang"><span>01</span> Chiếc ô màu vàng</a></h5>
            <h5><a href="#hat-mam-ben-cua-so"><span>02</span> Hạt mầm bên cửa sổ</a></h5>
            <h5><a href="#chuyen-xe-cuoi-ngay"><span>03</span> Chuyến xe cuối ngày</a></h5>
        </nav>

        <article class="story" id="chiec-o-mau-vang" aria-labelledby="story-one-title">
            <p class="story-number">Truyện 01</p>
            <h2 id="story-one-title">Chiếc ô màu vàng</h2>
            <p>Chiều ấy, cơn mưa đến sớm hơn mọi ngày. Linh đứng dưới mái hiên thư viện, ôm chiếc cặp vào lòng. Cô đã mang theo đủ sách vở, nhưng lại để quên chiếc ô ở nhà. Bên kia đường, một ông cụ đang chậm rãi kéo chiếc xe chở đầy những chậu hoa nhỏ.</p>
            <p>Một cậu bé đi ngang, cầm chiếc ô màu vàng. Cậu nhìn Linh rồi nhìn ông cụ, ngập ngừng vài giây. Sau đó, cậu chạy đến che ô cho ông và cùng đẩy xe vào mái hiên. Những giọt nước trên lá hoa rung lên như những hạt thuỷ tinh.</p>
            <p>Ông cụ tặng cậu một chậu cúc. Cậu lắc đầu, đặt chậu hoa lên bậc cửa thư viện rồi nói: “Để ở đây thì ngày mai ai cũng được ngắm.” Linh mỉm cười. Cơn mưa chưa tạnh, nhưng cô thấy buổi chiều đã sáng hơn rất nhiều.</p>
            <a class="back-link" href="#muc-luc">↑ Trở về mục lục</a>
        </article>

        <article class="story" id="hat-mam-ben-cua-so" aria-labelledby="story-two-title">
            <p class="story-number">Truyện 02</p>
            <h2 id="story-two-title">Hạt mầm bên cửa sổ</h2>
            <p>Nam gieo một hạt đậu vào chiếc cốc đất cũ. Mỗi sáng, cậu đều tưới nước rồi đứng nhìn rất lâu. Ba ngày trôi qua, mặt đất vẫn im lìm. Cậu bắt đầu nghĩ rằng hạt đậu đã quên nhiệm vụ của mình.</p>
            <p>Bà bảo: “Có những việc đang diễn ra ở nơi mình chưa nhìn thấy.” Nam không hiểu hết, nhưng cậu vẫn đặt chiếc cốc bên cửa sổ. Cậu tưới ít nước hơn, để đất không quá ướt, rồi quay lại với những bài tập còn dang dở.</p>
            <p>Một tuần sau, một mầm xanh nhỏ đội đất nhô lên. Nam gọi bà đến xem, vui như vừa tìm được kho báu. Bà chỉ vào chiếc rễ bé xíu bên thành cốc. Hoá ra, trước khi vươn lên đón nắng, hạt đậu đã dành nhiều ngày để đứng vững. Từ đó, Nam bớt sốt ruột với cả cây đậu lẫn chính mình.</p>
            <a class="back-link" href="#muc-luc">↑ Trở về mục lục</a>
        </article>

        <article class="story" id="chuyen-xe-cuoi-ngay" aria-labelledby="story-three-title">
            <p class="story-number">Truyện 03</p>
            <h2 id="story-three-title">Chuyến xe cuối ngày</h2>
            <p>Chuyến xe buýt cuối ngày chỉ còn vài hành khách. Minh ngồi sát cửa kính, nhìn những cửa hàng lần lượt tắt đèn. Hôm nay cậu làm hỏng bài thuyết trình, và câu nói vấp ở đầu bài cứ lặp lại trong đầu.</p>
            <p>Ở trạm tiếp theo, một cô bán bánh lên xe với chiếc giỏ trống. Khi tìm tiền vé, cô vô tình làm rơi những đồng xu xuống sàn. Minh cúi xuống nhặt giúp. Người ngồi phía trước cũng quay lại, bác tài đợi thêm một chút. Chẳng bao lâu, những đồng xu đã nằm gọn trong tay cô.</p>
            <p>“Cảm ơn cháu, hôm nay cô mệt quá,” cô nói. Minh chợt nhận ra mình không phải người duy nhất có một ngày khó khăn. Cậu xuống xe, lấy điện thoại nhắn cho nhóm: “Ngày mai mình tập lại nhé.” Trên con đường về nhà, bước chân cậu đã nhẹ hơn.</p>
            <a class="back-link" href="#muc-luc">↑ Trở về mục lục</a>
        </article>
        <footer>Góc truyện nhỏ · Nội dung truyện được viết cho bài thực hành.</footer>
    </main>
</body>
</html>

```

## styles.css

```css
:root {
    color-scheme: light;
    --ink: #273e39;
    --muted: #69766c;
    --accent: #386955;
    --border: #dedace;
}

* {
    box-sizing: border-box;
}

html {
    scroll-behavior: smooth;
}

body {
    margin: 0;
    background-color: #f5f2e9;
    color: var(--ink);
    font-family: Georgia, "Times New Roman", serif;
    font-size: 18px;
}

main {
    max-width: 840px;
    margin: 40px auto;
    padding: 0 24px;
}

.page-header {
    text-align: center;
}

.cover {
    display: block;
    width: 100%;
    height: auto;
    border-radius: 12px;
}

.eyebrow,
.story-number {
    color: var(--accent);
    font-family: Arial, sans-serif;
    font-size: 12px;
    letter-spacing: 2px;
    text-transform: uppercase;
}

.eyebrow {
    margin-top: 30px;
}

h1 {
    margin: 12px 0;
    font-size: clamp(36px, 6vw, 54px);
}

.intro {
    color: var(--muted);
    line-height: 1.6;
}

.contents {
    margin: 36px 0;
    border: 1px solid var(--border);
    border-radius: 10px;
    background-color: #fffdf6;
    padding: 24px;
}

.contents h2 {
    margin: 0 0 16px;
    font-size: 24px;
}

.contents h5 {
    margin: 0;
    font-size: 18px;
    font-weight: normal;
}

.contents a {
    display: block;
    padding: 12px 8px;
    border-radius: 5px;
    color: var(--ink);
    text-decoration: none;
}

.contents a span {
    margin-right: 16px;
    color: var(--muted);
    font-family: Arial, sans-serif;
    font-size: 13px;
}

.contents a:hover {
    background-color: #eaf0e6;
    color: var(--accent);
    text-decoration: underline;
}

a:focus-visible {
    outline: 2px solid var(--accent);
    outline-offset: 3px;
}

.story {
    margin-bottom: 32px;
    border: 1px solid var(--border);
    border-radius: 10px;
    background-color: #fffdf8;
    padding: 32px;
    scroll-margin-top: 24px;
}

.story-number {
    text-align: center;
}

.story h2 {
    margin: 12px 0 24px;
    color: var(--accent);
    font-size: 30px;
    text-align: center;
}

.story > p:not(.story-number) {
    margin: 0 0 18px;
    line-height: 1.85;
    text-align: justify;
    text-indent: 2em;
}

.back-link {
    display: inline-block;
    margin-top: 8px;
    color: var(--accent);
    font-family: Arial, sans-serif;
    font-size: 14px;
    text-decoration: none;
}

.back-link:hover {
    text-decoration: underline;
}

footer {
    padding: 10px 0 24px;
    color: var(--muted);
    font-size: 14px;
    text-align: center;
}

@media (max-width: 600px) {
    main {
        margin: 16px auto;
        padding: 0 16px;
    }

    .contents,
    .story {
        padding: 20px;
    }

    .story h2 {
        font-size: 26px;
    }
}

@media (prefers-reduced-motion: reduce) {
    html {
        scroll-behavior: auto;
    }
}

```