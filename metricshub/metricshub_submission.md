# MetricsHub — Bài nộp chung

File này gộp toàn bộ HTML, CSS, chiến lược và nhật ký AI. Tải thư mục metricshub_ui để chạy index.html cùng style.css; Bootstrap cần kết nối mạng.

[Gói ZIP theo đề](./metricshub_submission.zip)

## 1. metricshub_ui/index.html

```html
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>MetricsHub — Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet"
          integrity="sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB" crossorigin="anonymous">
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header class="site-header">
        <nav class="flex-navbar" aria-label="Main navigation">
            <a class="brand" href="#dashboard"><span class="brand-icon">M</span> MetricsHub</a>
            <div class="nav-links">
                <a href="#dashboard" data-en="Overview" data-de="Übersicht" aria-current="page">Overview</a>
                <a href="#dashboard" data-en="Analytics dashboard" data-de="VeryLongGermanWordForDashboard">Analytics dashboard</a>
                <a href="#pricing" data-en="Pricing" data-de="Preisgestaltung">Pricing</a>
            </div>
            <div class="nav-actions">
                <button id="language-toggle" type="button" aria-label="Switch navigation language to German">DE</button>
                <span class="profile" aria-label="Profile: Minh An">MA</span>
            </div>
        </nav>
    </header>

    <main class="container py-4 py-lg-5">
        <div class="page-heading" id="dashboard">
            <div><p class="eyebrow">YOUR WORKSPACE AT A GLANCE</p><h1>Every metric. One clear view.</h1></div>
            <span class="data-label">Sample dashboard data</span>
        </div>

        <!-- Mọi widget là con trực tiếp của grid-dashboard, không có wrapper .column. -->
        <div class="grid-dashboard" aria-label="Analytics widgets">
            <section class="widget widget-main" aria-labelledby="revenue-title">
                <div class="widget-heading"><h2 id="revenue-title">Revenue overview</h2><span class="period">Last 7 months</span></div>
                <p class="metric">$48,520</p><p class="trend">↗ 12.8% <span>vs. previous period</span></p>
                <svg class="revenue-chart" viewBox="0 0 520 270" role="img" aria-labelledby="chart-title chart-desc">
                    <title id="chart-title">Sample revenue trend</title>
                    <desc id="chart-desc">Illustrative revenue rises from January to July with a dip in April. The chart is mock data.</desc>
                    <defs><linearGradient id="area" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#3976d8" stop-opacity=".25"/><stop offset="100%" stop-color="#3976d8" stop-opacity="0"/></linearGradient></defs>
                    <g stroke="#e7edf5"><path d="M20 45H500 M20 100H500 M20 155H500 M20 210H500"/></g>
                    <path d="M20 190L100 150L180 165L260 115L340 85L420 100L500 40V215H20Z" fill="url(#area)"/>
                    <path d="M20 190L100 150L180 165L260 115L340 85L420 100L500 40" stroke="#3976d8" stroke-width="4" fill="none" stroke-linejoin="round"/>
                    <g fill="#748195" font-family="Arial" font-size="13"><text x="12" y="245">Jan</text><text x="92" y="245">Feb</text><text x="172" y="245">Mar</text><text x="252" y="245">Apr</text><text x="332" y="245">May</text><text x="412" y="245">Jun</text><text x="486" y="245">Jul</text></g>
                </svg>
                <p class="chart-caption">A steady month, with room to grow.</p>
            </section>

            <section class="widget" aria-labelledby="users-title">
                <h2 id="users-title">Active users</h2><p class="metric">8,240</p>
                <p class="trend">↗ 6.4% <span>this month</span></p>
                <div class="spark-bars" aria-hidden="true"><span style="--bar:35%"></span><span style="--bar:55%"></span><span style="--bar:45%"></span><span style="--bar:70%"></span><span style="--bar:60%"></span><span style="--bar:85%"></span><span style="--bar:100%"></span></div>
            </section>

            <section class="widget widget-highlight" aria-labelledby="conversion-title">
                <h2 id="conversion-title">Conversion rate</h2><p class="metric">4.8%</p>
                <p class="trend">↗ 0.6 points <span>this month</span></p>
                <p class="small-note">More visits are turning into meaningful action.</p>
            </section>

            <section class="widget widget-wide" aria-labelledby="channels-title">
                <h2 id="channels-title">Top acquisition channels</h2>
                <div class="channel"><span>Organic search</span><div class="channel-track"><span style="width:72%"></span></div><strong>72%</strong></div>
                <div class="channel"><span>Direct traffic</span><div class="channel-track"><span style="width:48%"></span></div><strong>48%</strong></div>
                <div class="channel"><span>Social</span><div class="channel-track"><span style="width:31%"></span></div><strong>31%</strong></div>
                <p class="small-note">Independent sample scores, not a percentage breakdown.</p>
            </section>

            <section class="widget" aria-labelledby="health-title">
                <h2 id="health-title">Workspace health</h2>
                <div class="health-indicator"><span class="health-dot"></span><strong>All systems ready</strong></div>
                <p class="small-note">Your sample reports are up to date.</p>
            </section>
        </div>

        <!-- Bảng giá dùng Bootstrap; không có CSS riêng để chia cột bảng giá. -->
        <section id="pricing" class="mt-5" aria-labelledby="pricing-title">
            <div class="mb-4"><p class="eyebrow">PLANS FOR EVERY STAGE</p><h2 id="pricing-title" class="h3 fw-bold">A little clarity goes a long way.</h2><p class="text-secondary">Illustrative plans for the layout exercise.</p></div>
            <div class="row g-4">
                <div class="col-12 col-md-4">
                    <div class="card h-100 border-0 shadow-sm"><div class="card-body p-4 d-flex flex-column">
                        <h3 class="h5">Starter</h3><p class="text-secondary">For your first dashboard.</p><p class="display-6 fw-bold">$0<span class="fs-6 fw-normal text-secondary"> / month</span></p>
                        <ul class="text-secondary ps-3"><li>One workspace</li><li>Basic reports</li><li>Community resources</li></ul>
                        <a href="#dashboard" class="btn btn-outline-primary mt-auto">Explore Starter</a>
                    </div></div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="card h-100 border-primary shadow-sm"><div class="card-body p-4 d-flex flex-column">
                        <h3 class="h5">Growth <span class="badge text-bg-primary ms-1">Popular</span></h3><p class="text-secondary">For a team finding its rhythm.</p><p class="display-6 fw-bold">$19<span class="fs-6 fw-normal text-secondary"> / month</span></p>
                        <ul class="text-secondary ps-3"><li>Five workspaces</li><li>Advanced reports</li><li>Team collaboration</li></ul>
                        <a href="#dashboard" class="btn btn-primary mt-auto">Explore Growth</a>
                    </div></div>
                </div>
                <div class="col-12 col-md-4">
                    <div class="card h-100 border-0 shadow-sm"><div class="card-body p-4 d-flex flex-column">
                        <h3 class="h5">Enterprise</h3><p class="text-secondary">For a bigger picture.</p><p class="display-6 fw-bold">Custom</p>
                        <ul class="text-secondary ps-3"><li>Flexible workspaces</li><li>Custom reporting</li><li>Dedicated support</li></ul>
                        <a href="#dashboard" class="btn btn-outline-primary mt-auto">Explore Enterprise</a>
                    </div></div>
                </div>
            </div>
        </section>
        <footer class="text-center text-secondary small mt-5">MetricsHub · Flexbox + CSS Grid + Bootstrap · Layout demonstration</footer>
    </main>
    <script>
        const toggle = document.getElementById('language-toggle');
        let language = 'en';
        toggle.addEventListener('click', () => {
            language = language === 'en' ? 'de' : 'en';
            document.querySelectorAll('.nav-links a').forEach((link) => {
                link.textContent = link.dataset[language];
                link.lang = language;
            });
            toggle.textContent = language === 'en' ? 'DE' : 'EN';
            toggle.setAttribute('aria-label', `Switch navigation language to ${language === 'en' ? 'German' : 'English'}`);
        });
    </script>
</body>
</html>

```

## 2. metricshub_ui/style.css

```css
:root {
    --ink: #203048;
    --muted: #788496;
    --accent: #3976d8;
}

body {
    color: var(--ink);
    background: #f4f6fa;
}

.site-header {
    border-bottom: 1px solid #e2e7ef;
    background: white;
}

/* Navbar: phân bố theo nội dung, có wrap để xử lý nhãn dài. */
.flex-navbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 16px 24px;
    max-width: 1320px;
    margin: 0 auto;
    padding: 18px 24px;
}

.brand {
    display: flex;
    align-items: center;
    gap: 10px;
    color: var(--ink);
    font-size: 21px;
    font-weight: 750;
    text-decoration: none;
}

.brand-icon {
    display: grid;
    place-items: center;
    width: 34px;
    height: 34px;
    border-radius: 10px;
    color: white;
    background: var(--accent);
    font-size: 20px;
}

.nav-links {
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 1 1 320px;
    flex-wrap: wrap;
    min-width: 0;
    gap: 12px 24px;
}

.nav-links a {
    max-width: 100%;
    color: #647086;
    font-size: 14px;
    text-decoration: none;
    overflow-wrap: anywhere;
}

.nav-links a:hover,
.nav-links a[aria-current="page"] {
    color: var(--accent);
}

.nav-actions {
    display: flex;
    align-items: center;
    gap: 12px;
}

.nav-actions button {
    border: 1px solid #dce3ee;
    border-radius: 8px;
    padding: 7px 10px;
    background: white;
    color: var(--ink);
    font-size: 13px;
}

.profile {
    display: grid;
    place-items: center;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    color: #51705f;
    background: #e3eee6;
    font-size: 12px;
    font-weight: bold;
}

.page-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 16px;
    margin-bottom: 28px;
}

.eyebrow {
    margin-bottom: 10px;
    color: var(--muted);
    font-size: 11px;
    font-weight: 650;
    letter-spacing: 1.6px;
}

h1 {
    margin: 0;
    font-size: clamp(26px, 4vw, 36px);
    font-weight: 750;
    letter-spacing: -1px;
}

.data-label,
.period {
    color: var(--muted);
    font-size: 12px;
}

/* Bento: widget anh em trực tiếp, bố cục hai chiều và span. */
.grid-dashboard {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 20px;
}

.widget {
    min-width: 0;
    border: 1px solid #e2e7f0;
    border-radius: 16px;
    padding: 24px;
    background: white;
}

.widget-main {
    grid-column: span 2;
    grid-row: span 2;
}

.widget-wide {
    grid-column: span 2;
}

.widget-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px;
}

.widget h2 {
    margin: 0 0 18px;
    font-size: 15px;
    font-weight: 650;
}

.widget-heading h2 {
    margin-bottom: 0;
}

.metric {
    margin: 20px 0 6px;
    font-size: clamp(28px, 4vw, 40px);
    font-weight: 750;
    letter-spacing: -1px;
}

.trend {
    margin: 0;
    color: #247855;
    font-size: 13px;
}

.trend span {
    margin-left: 6px;
    color: var(--muted);
}

.revenue-chart {
    display: block;
    width: 100%;
    height: auto;
    margin-top: 28px;
}

.chart-caption,
.small-note {
    margin: 16px 0 0;
    color: var(--muted);
    font-size: 13px;
    line-height: 1.7;
}

.spark-bars {
    display: flex;
    align-items: flex-end;
    gap: 8px;
    height: 50px;
    margin-top: 20px;
}

.spark-bars span {
    flex: 1;
    height: var(--bar);
    border-radius: 4px 4px 0 0;
    background: #b9cfee;
}

.widget-highlight {
    background: #edf4ff;
}

.channel {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    gap: 10px 14px;
    margin-top: 16px;
    font-size: 13px;
}

.channel > span {
    flex: 0 1 110px;
}

.channel-track {
    flex: 1 1 100px;
    min-width: 0;
    height: 7px;
    border-radius: 8px;
    background: #eef2f7;
}

.channel-track span {
    display: block;
    height: 100%;
    border-radius: inherit;
    background: #759bdc;
}

.health-indicator {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 15px;
}

.health-dot {
    flex-shrink: 0;
    width: 9px;
    height: 9px;
    border-radius: 50%;
    background: #34996a;
}

@media (max-width: 991px) {
    .grid-dashboard {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }

    .widget-main {
        grid-column: span 2;
        grid-row: auto;
    }

    .widget-wide {
        grid-column: span 2;
    }
}

@media (max-width: 575px) {
    .flex-navbar {
        padding: 16px;
    }

    .nav-links {
        order: 3;
        flex-basis: 100%;
        justify-content: flex-start;
        gap: 12px 16px;
    }

    .grid-dashboard {
        grid-template-columns: minmax(0, 1fr);
        gap: 16px;
    }

    .widget-main,
    .widget-wide {
        grid-column: auto;
        grid-row: auto;
    }

    .widget {
        padding: 20px;
    }
}

```

## 3. layout_strategy.md

# Chiến lược dàn trang MetricsHub

Navbar dùng Flexbox vì các mục được phân bố theo một chiều và độ dài nội dung thay đổi. flex-wrap, min-width và overflow-wrap giúp nhãn tiếng Đức xuống dòng thay vì chồng lên logo.

Dashboard dùng Grid vì cần điều khiển đồng thời hàng và cột. Các widget là con trực tiếp; widget lớn span hai hàng, hai cột. Desktop có ba cột, tablet hai cột, mobile một cột và bỏ span.

Pricing dùng row, col-12 col-md-4, card của Bootstrap: ba cột từ 768px, xếp dọc phía dưới, không viết CSS riêng chia cột. Grid và Flexbox có thể phối hợp: bên trong widget, Flexbox căn biểu tượng cùng chữ. Đây là lựa chọn theo yêu cầu bố cục, không phải quy tắc cấm dùng Grid cho component hoặc Flexbox cho layout.


## 4. ai_prompt_log.md

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


## Tự kiểm tra responsive

- 1280px: dashboard 3 cột, widget chính 2x2, bảng giá 3 cột.
- 768px: dashboard 2 cột, widget chính chiếm 2 cột; bảng giá 3 cột theo breakpoint md.
- 375px: dashboard và bảng giá 1 cột, navbar đẩy menu xuống dưới logo.
- Bấm DE để thử VeryLongGermanWordForDashboard; kiểm tra không có thanh cuộn ngang và các mục không chồng lên nhau.
- Đây là checklist cần chạy trong trình duyệt, chưa phải kết quả đã kiểm chứng trực quan.