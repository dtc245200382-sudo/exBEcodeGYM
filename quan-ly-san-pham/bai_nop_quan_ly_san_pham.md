# [Bài tập] Tạo ứng dụng quản lý sản phẩm theo MVC

Mã số sinh viên: **DTC245200382**.

Ngày hoàn thành và kiểm thử: **13/10/2026**.

Ứng dụng JSP/Servlet có đầy đủ sáu chức năng của đề, dùng `ProductService` và `ProductServiceImpl` với Map tĩnh để giả lập dữ liệu. Tài liệu này gom hướng dẫn, kết quả kiểm thử và toàn bộ mã nguồn vào một file. Dự án Maven để chạy nằm trong thư mục `product-mvc` bên cạnh tài liệu này.

## 1. Đối chiếu yêu cầu

| Yêu cầu | Cách thực hiện |
| --- | --- |
| Danh sách sản phẩm | Bảng gồm ID, tên, giá, mô tả, nhà sản xuất và các liên kết Xem/Sửa/Xoá |
| Tạo sản phẩm | Form tên, giá, mô tả, nhà sản xuất; Service tự cấp ID mới |
| Cập nhật | Mở form có thông tin hiện tại theo ID rồi gửi POST để lưu |
| Xoá | Trang xác nhận xoá có nút Xác nhận và Huỷ; GET chỉ mở trang, POST mới xoá |
| Xem chi tiết | Hiển thị toàn bộ năm thuộc tính của sản phẩm |
| Tìm theo tên | Tìm một phần tên, không phân biệt hoa/thường, bỏ khoảng trắng ở hai đầu; có nút Xem tất cả |

`Product` có các thuộc tính `id`, `name`, `price`, `description`, `manufacturer`. Giá dùng `BigDecimal` để giữ chính xác hai chữ số thập phân. Tên và nhà sản xuất bắt buộc, tối đa 255 ký tự; mô tả tối đa 2000 ký tự; giá không âm và không vượt 9999999999999.99. Lỗi nhập liệu được kiểm tra trên server, trả về biểu mẫu với dữ liệu đã nhập.

Service chứa 5 sản phẩm mẫu. ID tự tăng và không dùng lại trong một lần chạy; thao tác với Map được đồng bộ để tránh trùng ID khi có nhiều yêu cầu thêm cùng lúc. Các đối tượng `Product` bất biến và danh sách trả về là bản sao, tránh sửa dữ liệu Map từ bên ngoài Service.

**Dữ liệu lưu trong bộ nhớ theo yêu cầu giả lập:** các phiên trình duyệt dùng chung danh sách; khi Tomcat khởi động lại hoặc ứng dụng được triển khai lại, danh sách trở về 5 sản phẩm mẫu. Không cần MySQL hoặc import SQL để chạy bài này.

## 2. Kiến trúc MVC

```text
Trình duyệt
    ↓ GET/POST /products?action=...
ProductServlet (Controller)
    ↓
ProductService → ProductServiceImpl → Map<Integer, Product> (Model/Service)
    ↓ dữ liệu đặt vào request
JSP + JSTL (View)
    ↓
HTML trả về trình duyệt
```

- `ProductServlet` điều hướng theo `action`, không chứa Map lưu sản phẩm.
- `ProductService` khai báo hợp đồng; `ProductServiceImpl` thực hiện quản lý dữ liệu và tìm kiếm.
- `ProductForm` giữ chuỗi gốc của biểu mẫu khi người dùng nhập sai.
- JSP sử dụng JSTL `jakarta.tags.core`; không chứa Java scriptlet xử lý nghiệp vụ.
- Các JSP nằm trong `WEB-INF` và được truy cập qua Servlet.

## 3. Cấu trúc dự án

```text
product-mvc/
├── .gitignore
├── pom.xml
├── scripts/smoke-test.ps1
└── src/
    ├── main/
    │   ├── java/com/codegym/
    │   │   ├── model/Product.java
    │   │   ├── service/ProductService.java
    │   │   ├── service/ProductServiceImpl.java
    │   │   ├── controller/ProductForm.java
    │   │   └── controller/ProductServlet.java
    │   └── webapp/
    │       ├── assets/styles.css
    │       └── WEB-INF/
    │           ├── web.xml
    │           └── views/
    │               ├── list.jsp
    │               ├── form.jsp
    │               ├── view.jsp
    │               ├── delete.jsp
    │               ├── error.jsp
    │               └── fragments/{header,footer}.jspf
    └── test/java/com/codegym/service/ProductServiceTest.java
```

Form thêm và sửa dùng chung `form.jsp`. Giao diện có CSS responsive, bảng có thể cuộn ngang trên màn hình nhỏ, các nhãn form gắn với ô nhập và có đánh dấu focus khi dùng bàn phím.

## 4. Cách chạy

Môi trường: **JDK 17**, **Maven 3.9 trở lên**, **Apache Tomcat 10.1.x**. Dự án dùng `jakarta.servlet`, Servlet 6.0 và JSTL 3.0.

Tải mã nguồn, mở terminal trong thư mục `product-mvc` rồi chạy:

```powershell
mvn clean package
```

Maven tạo `target/product-mvc.war`. Copy WAR vào thư mục `webapps` của Tomcat và khởi động Tomcat. Ví dụ PowerShell, thay đường dẫn theo máy của bạn:

```powershell
$env:JAVA_HOME = 'C:\Java\jdk-17'
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
$tomcatPath = 'C:\tools\apache-tomcat-10.1'
Copy-Item .\target\product-mvc.war "$tomcatPath\webapps\product-mvc.war"
& "$tomcatPath\bin\catalina.bat" run
```

Mở **http://localhost:8080/product-mvc/** hoặc **http://localhost:8080/product-mvc/products**. Nếu Tomcat dùng cổng khác, thay 8080 bằng cổng đó.

| Phương thức | URL/action | Chức năng |
| --- | --- | --- |
| GET | `/products` | Danh sách |
| GET | `/products?action=search&keyword=...` | Tìm kiếm |
| GET | `/products?action=create` | Form thêm |
| GET | `/products?action=edit&id=...` | Form sửa |
| GET | `/products?action=view&id=...` | Chi tiết |
| GET | `/products?action=delete&id=...` | Xác nhận xoá |
| POST | `action=create` | Thêm sản phẩm |
| POST | `action=edit` | Lưu sửa |
| POST | `action=delete`, `confirmed=yes` | Xoá đã xác nhận |

Các POST gửi mã CSRF có trong form. Sau khi ghi dữ liệu thành công, server chuyển về danh sách bằng HTTP 303; tải lại trang không gửi thêm sản phẩm lần nữa. Dữ liệu người dùng được escape bằng `c:out` khi hiển thị ở bảng, form và trang chi tiết. ID sai định dạng trả về 400; ID không tồn tại trả về 404.

Từng file JSP/JSP fragment khai báo UTF-8 để văn bản tiếng Việt hiển thị đúng cả ở phần tĩnh và phần lấy từ Model.

## 5. Kiểm thử và kết quả

```powershell
# Kiểm thử Java
mvn test

# Kiểm tra HTTP sau khi đã khởi động ứng dụng
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test.ps1 `
    -BaseUrl 'http://localhost:8080/product-mvc'
```

Đã chạy thực tế với JDK **17.0.20.1**, Maven **3.9.9**, Apache Tomcat **10.1.61** tại `127.0.0.1:18780/product-mvc`:

- **BUILD SUCCESS**.
- **10 kiểm thử JUnit đạt**, không lỗi hoặc bài bị bỏ qua. Có kiểm tra 40 lượt thêm từ 8 luồng cho ID khác nhau, tìm kiếm tiếng Việt, cập nhật/xoá và dữ liệu không hợp lệ.
- **32 kiểm tra HTTP đạt**, bao gồm đầy đủ sáu chức năng, biểu mẫu tự điền, xác nhận xoá, CSRF, escape HTML, sửa bản ghi đã xoá và nội dung tiếng Việt.
- Script HTTP chỉ tạo và dọn sản phẩm của lượt thử đó; không xoá sản phẩm mẫu.

Kiểm thử giao diện qua HTML trả về và luồng HTTP; chưa thực hiện kiểm tra trực quan bằng ảnh chụp trình duyệt. Log thực tế và mã nguồn ở các mục dưới.

## 6. Tham khảo

Mã được tạo cho bài tập này với hỗ trợ ChatGPT/Codex. Cấu hình Maven, kiểu CSS và khung kiểm tra HTTP được điều chỉnh từ các bài trước trong cùng repository.

- [Apache Tomcat 10.1 — Servlet 6.0 và JSP 3.1](https://tomcat.apache.org/tomcat-10.1-doc/index.html).
- [Jakarta Standard Tag Library 3.0](https://jakarta.ee/specifications/tags/3.0/) — JSTL Jakarta dùng namespace `jakarta.tags.*`.

## 7. Log kiểm thử thực tế

### product-mvc-build.log

```text
[INFO] Scanning for projects...
[INFO]
[INFO] ----------------------< com.codegym:product-mvc >-----------------------
[INFO] Building product-mvc 1.0-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ war ]---------------------------------
[INFO]
[INFO] --- clean:3.2.0:clean (default-clean) @ product-mvc ---
[INFO] Deleting E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-san-pham\product-mvc\target
[INFO]
[INFO] --- resources:3.3.1:resources (default-resources) @ product-mvc ---
[INFO] skip non existing resourceDirectory E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-san-pham\product-mvc\src\main\resources
[INFO]
[INFO] --- compiler:3.13.0:compile (default-compile) @ product-mvc ---
[INFO] Recompiling the module because of changed source code.
[INFO] Compiling 5 source files with javac [debug release 17] to target\classes
[INFO]
[INFO] --- resources:3.3.1:testResources (default-testResources) @ product-mvc ---
[INFO] skip non existing resourceDirectory E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-san-pham\product-mvc\src\test\resources
[INFO]
[INFO] --- compiler:3.13.0:testCompile (default-testCompile) @ product-mvc ---
[INFO] Recompiling the module because of changed dependency.
[INFO] Compiling 1 source file with javac [debug release 17] to target\test-classes
[INFO]
[INFO] --- surefire:3.2.5:test (default-test) @ product-mvc ---
[INFO] Using auto detected provider org.apache.maven.surefire.junitplatform.JUnitPlatformProvider
[INFO]
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.codegym.service.ProductServiceTest
[INFO] Tests run: 10, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.076 s -- in com.codegym.service.ProductServiceTest
[INFO]
[INFO] Results:
[INFO]
[INFO] Tests run: 10, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO]
[INFO] --- war:3.4.0:war (default-war) @ product-mvc ---
[INFO] Packaging webapp
[INFO] Assembling webapp [product-mvc] in [E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-san-pham\product-mvc\target\product-mvc]
[INFO] Processing war project
[INFO] Copying webapp resources [E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-san-pham\product-mvc\src\main\webapp]
[INFO] Building war: E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-san-pham\product-mvc\target\product-mvc.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  3.085 s
[INFO] Finished at: 2026-10-13T19:21:56+07:00
[INFO] ------------------------------------------------------------------------
```

### product-mvc-http-verification.txt

```text
PASS: List displays seeded products and all required attributes
PASS: Application root opens the list servlet
PASS: Responsive stylesheet loads
PASS: Partial Vietnamese name search ignores case and surrounding spaces
PASS: A search with no matches displays an empty state
PASS: Create form loads with all fields and a CSRF token
PASS: A mutation without a CSRF token is rejected
PASS: Blank product names are rejected on the server
PASS: Invalid prices keep the original form data
PASS: Blank manufacturers are rejected
PASS: Creating a product redirects to the list
PASS: New product, decimal price and success message are visible
PASS: Refreshing does not duplicate the created product
PASS: Detail page displays name, price, description and manufacturer
PASS: Another session sees the same static Map data
PASS: Edit form is prefilled with the saved product
PASS: Editing the product succeeds
PASS: Updated price and manufacturer are stored
PASS: JSTL escapes user content on the detail page
PASS: Edit form also escapes the existing user content
PASS: Negative price updates are rejected
PASS: Rejected edits leave the stored product unchanged
PASS: Searching finds the renamed product
PASS: Search matches names rather than descriptions
PASS: Delete opens a confirmation page
PASS: Opening or cancelling the delete page leaves the product intact
PASS: Unconfirmed deletion is rejected
PASS: Confirmed deletion succeeds
PASS: Deleted products no longer have a detail page
PASS: A stale edit cannot recreate a deleted product
PASS: Malformed IDs receive an error page
PASS: JSP templates cannot be accessed directly
RESULT: 32 HTTP checks passed
```

## 8. Toàn bộ mã nguồn

### .gitignore

```text
/target/
/.idea/
*.iml
*.log
```

### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>product-mvc</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <properties>
        <maven.compiler.release>17</maven.compiler.release>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>
        <dependency>
            <groupId>jakarta.servlet</groupId>
            <artifactId>jakarta.servlet-api</artifactId>
            <version>6.0.0</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp.jstl</groupId>
            <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
            <version>3.0.0</version>
        </dependency>
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.11.4</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <finalName>product-mvc</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.13.0</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-war-plugin</artifactId>
                <version>3.4.0</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
            </plugin>
        </plugins>
    </build>
</project>
```

### scripts/smoke-test.ps1

```powershell
param([string]$BaseUrl = 'http://localhost:8080/product-mvc')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Net.Http
$BaseUrl = $BaseUrl.TrimEnd('/')
$handler = [System.Net.Http.HttpClientHandler]::new()
$handler.AllowAutoRedirect = $false
$handler.CookieContainer = [System.Net.CookieContainer]::new()
$client = [System.Net.Http.HttpClient]::new($handler)
$client.Timeout = [TimeSpan]::FromSeconds(20)
$checks = [Collections.Generic.List[string]]::new()
$createdIds = [Collections.Generic.List[int]]::new()
$csrf = ''

function Send-Request([string]$Method, [string]$Path, [hashtable]$Form = @{}) {
    $message = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::new($Method), "$BaseUrl$Path")
    if ($Method -eq 'POST') {
        $fields = [Collections.Generic.Dictionary[string,string]]::new()
        foreach ($key in $Form.Keys) { $fields.Add($key, [string]$Form[$key]) }
        $message.Content = [System.Net.Http.FormUrlEncodedContent]::new($fields)
    }
    try {
        $response = $client.SendAsync($message).GetAwaiter().GetResult()
        try {
            [pscustomobject]@{ Status = [int]$response.StatusCode; Body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult(); Location = [string]$response.Headers.Location }
        } finally { $response.Dispose() }
    } finally { $message.Dispose() }
}

function Check([bool]$Condition, [string]$Description) {
    if (-not $Condition) { throw "FAIL: $Description" }
    $line = "PASS: $Description"
    $checks.Add($line)
    Write-Output $line
}

function Find-ProductId([string]$Body, [string]$Name) {
    foreach ($row in [regex]::Matches($Body, '(?s)<tr data-product-id="(\d+)">.*?</tr>')) {
        if ($row.Value.Contains($Name)) { return [int]$row.Groups[1].Value }
    }
    throw "Product not found: $Name"
}

try {
    $list = Send-Request GET '/products'
    Check ($list.Status -eq 200 -and $list.Body.Contains('Bàn phím cơ') -and $list.Body.Contains('Nhà sản xuất')) 'List displays seeded products and all required attributes'
    $root = Send-Request GET '/'
    Check ($root.Status -eq 200 -and $root.Body.Contains('Danh sách sản phẩm')) 'Application root opens the list servlet'
    $css = Send-Request GET '/assets/styles.css'
    Check ($css.Status -eq 200 -and $css.Body.Contains('@media')) 'Responsive stylesheet loads'
    $search = Send-Request GET ('/products?action=search&keyword=' + [Uri]::EscapeDataString(' BÀN PHÍM '))
    Check ($search.Status -eq 200 -and ([regex]::Matches($search.Body, 'data-product-id=')).Count -eq 2) 'Partial Vietnamese name search ignores case and surrounding spaces'
    $search = Send-Request GET '/products?action=search&keyword=not-found-unique-xyz'
    Check ($search.Status -eq 200 -and $search.Body.Contains('Không có sản phẩm phù hợp.')) 'A search with no matches displays an empty state'
    $form = Send-Request GET '/products?action=create'
    $csrfMatch = [regex]::Match($form.Body, 'name="csrf" value="([^"]+)"')
    Check ($form.Status -eq 200 -and $csrfMatch.Success -and $form.Body.Contains('name="manufacturer"')) 'Create form loads with all fields and a CSRF token'
    $csrf = $csrfMatch.Groups[1].Value
    $forbidden = Send-Request POST '/products' @{action='create'; name='Rejected'; price='1'; manufacturer='A'}
    Check ($forbidden.Status -eq 403) 'A mutation without a CSRF token is rejected'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=''; price='1'; manufacturer='A'}
    Check ($invalid.Status -eq 400) 'Blank product names are rejected on the server'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name='Tên chưa lưu'; price='1.001'; description='Nội dung giữ lại'; manufacturer='A'}
    Check ($invalid.Status -eq 400 -and $invalid.Body.Contains('Tên chưa lưu') -and $invalid.Body.Contains('Nội dung giữ lại')) 'Invalid prices keep the original form data'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name='A'; price='1'; manufacturer=''}
    Check ($invalid.Status -eq 400) 'Blank manufacturers are rejected'

    $suffix = [Guid]::NewGuid().ToString('N').Substring(0, 10)
    $originalName = "Sản phẩm thử $suffix"
    $description = "Mô tả nhiều dòng`nNội dung chi tiết $suffix"
    $created = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=$originalName; price='12345.67'; description=$description; manufacturer='Hãng Việt'}
    Check ($created.Status -eq 303 -and $created.Location.EndsWith('/products')) 'Creating a product redirects to the list'
    $list = Send-Request GET '/products'
    $productId = Find-ProductId $list.Body $originalName
    $createdIds.Add($productId)
    Check ($list.Body.Contains('12345.67') -and $list.Body.Contains('Đã thêm sản phẩm.')) 'New product, decimal price and success message are visible'
    $refresh = Send-Request GET '/products'
    Check (([regex]::Matches($refresh.Body, [regex]::Escape($originalName))).Count -eq 1) 'Refreshing does not duplicate the created product'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Status -eq 200 -and $view.Body.Contains($originalName) -and $view.Body.Contains($description) -and $view.Body.Contains('Hãng Việt')) 'Detail page displays name, price, description and manufacturer'
    $freshClient = [System.Net.Http.HttpClient]::new()
    try {
        $shared = $freshClient.GetStringAsync("$BaseUrl/products?action=view&id=$productId").GetAwaiter().GetResult()
        Check ($shared.Contains($originalName)) 'Another session sees the same static Map data'
    } finally { $freshClient.Dispose() }
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Status -eq 200 -and $edit.Body.Contains($originalName) -and $edit.Body.Contains('value="12345.67"') -and $edit.Body.Contains('Hãng Việt')) 'Edit form is prefilled with the saved product'

    $changedName = "Đã sửa $suffix <script>alert(1)</script>"
    $changedDescription = "Mô tả <img src=x onerror=alert(1)> $suffix"
    $updated = Send-Request POST '/products' @{action='edit'; csrf=$csrf; id=$productId; name=$changedName; price='99.10'; description=$changedDescription; manufacturer='Hãng mới'}
    Check ($updated.Status -eq 303) 'Editing the product succeeds'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Body.Contains('99.10') -and $view.Body.Contains('Hãng mới')) 'Updated price and manufacturer are stored'
    Check ($view.Body.Contains('&lt;script&gt;') -and $view.Body.Contains('&lt;img') -and -not $view.Body.Contains('<script>') -and -not $view.Body.Contains('<img src=x')) 'JSTL escapes user content on the detail page'
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Body.Contains('&lt;script&gt;') -and -not $edit.Body.Contains('<script>')) 'Edit form also escapes the existing user content'
    $invalid = Send-Request POST '/products' @{action='edit'; csrf=$csrf; id=$productId; name='A'; price='-9'; description=''; manufacturer='B'}
    Check ($invalid.Status -eq 400) 'Negative price updates are rejected'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Body.Contains('99.10') -and $view.Body.Contains('Hãng mới')) 'Rejected edits leave the stored product unchanged'
    $search = Send-Request GET ('/products?action=search&keyword=' + [Uri]::EscapeDataString("ĐÃ SỬA $suffix"))
    Check (([regex]::Matches($search.Body, 'data-product-id=')).Count -eq 1) 'Searching finds the renamed product'
    $search = Send-Request GET ('/products?action=search&keyword=' + [Uri]::EscapeDataString('Mô tả <img'))
    Check (([regex]::Matches($search.Body, 'data-product-id=')).Count -eq 0) 'Search matches names rather than descriptions'

    $confirmation = Send-Request GET "/products?action=delete&id=$productId"
    Check ($confirmation.Status -eq 200 -and $confirmation.Body.Contains('Xác nhận xoá') -and $confirmation.Body.Contains('name="confirmed" value="yes"')) 'Delete opens a confirmation page'
    $view = Send-Request GET "/products?action=view&id=$productId"
    Check ($view.Status -eq 200) 'Opening or cancelling the delete page leaves the product intact'
    $unconfirmed = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId}
    Check ($unconfirmed.Status -eq 400) 'Unconfirmed deletion is rejected'
    $deleted = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId; confirmed='yes'}
    Check ($deleted.Status -eq 303) 'Confirmed deletion succeeds'
    $missing = Send-Request GET "/products?action=view&id=$productId"
    Check ($missing.Status -eq 404) 'Deleted products no longer have a detail page'
    $stale = Send-Request POST '/products' @{action='edit'; csrf=$csrf; id=$productId; name='Stale'; price='1'; manufacturer='A'}
    Check ($stale.Status -eq 404) 'A stale edit cannot recreate a deleted product'
    $badId = Send-Request GET '/products?action=view&id=abc'
    Check ($badId.Status -eq 400) 'Malformed IDs receive an error page'
    $private = Send-Request GET '/WEB-INF/views/list.jsp'
    Check ($private.Status -eq 404) 'JSP templates cannot be accessed directly'
    Write-Output "RESULT: $($checks.Count) HTTP checks passed"
} finally {
    foreach ($createdId in $createdIds) {
        try { $null = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$createdId; confirmed='yes'} } catch { }
    }
    $client.Dispose()
}
```

### src/main/java/com/codegym/controller/ProductForm.java

```java
package com.codegym.controller;

import com.codegym.model.Product;
import java.math.BigDecimal;

/** Giữ dữ liệu gốc để biểu mẫu không bị mất nội dung khi nhập sai. */
public class ProductForm {
    private final int id;
    private final String name;
    private final String price;
    private final String description;
    private final String manufacturer;

    public ProductForm(int id, String name, String price, String description, String manufacturer) {
        this.id = id;
        this.name = text(name);
        this.price = text(price);
        this.description = text(description);
        this.manufacturer = text(manufacturer);
    }

    public static ProductForm empty() { return new ProductForm(0, "", "", "", ""); }
    public static ProductForm from(Product product) {
        return new ProductForm(product.getId(), product.getName(), product.getPrice().toPlainString(),
                product.getDescription(), product.getManufacturer());
    }

    public Product toProduct() {
        String cleanPrice = price.strip();
        if (cleanPrice.length() > 32 || !cleanPrice.matches("[0-9]+(?:\\.[0-9]{1,2})?"))
            throw new IllegalArgumentException("Giá phải là số không âm, tối đa 2 chữ số thập phân (dùng dấu chấm).");
        return new Product(id, name, new BigDecimal(cleanPrice), description, manufacturer);
    }

    private static String text(String value) { return value == null ? "" : value; }
    public int getId() { return id; }
    public String getName() { return name; }
    public String getPrice() { return price; }
    public String getDescription() { return description; }
    public String getManufacturer() { return manufacturer; }
}
```

### src/main/java/com/codegym/controller/ProductServlet.java

```java
package com.codegym.controller;

import com.codegym.model.Product;
import com.codegym.service.ProductService;
import com.codegym.service.ProductServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

public class ProductServlet extends HttpServlet {
    private final ProductService productService = new ProductServiceImpl();

    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        try {
            switch (action(request, "list")) {
                case "list", "search" -> {
                    String keyword = request.getParameter("keyword");
                    keyword = keyword == null ? "" : keyword.strip();
                    request.setAttribute("keyword", keyword);
                    request.setAttribute("products", productService.searchByName(keyword));
                    request.setAttribute("message", request.getSession().getAttribute("message"));
                    request.getSession().removeAttribute("message");
                    render("list", "Danh sách sản phẩm", request, response);
                }
                case "create" -> {
                    request.setAttribute("form", ProductForm.empty());
                    render("form", "Thêm sản phẩm", request, response);
                }
                case "edit", "delete", "view" -> {
                    Product product = productService.findById(id(request));
                    if (product == null) {
                        error(404, "Không tìm thấy sản phẩm.", request, response);
                        return;
                    }
                    request.setAttribute("product", product);
                    switch (action(request, "")) {
                        case "edit" -> {
                            request.setAttribute("form", ProductForm.from(product));
                            render("form", "Sửa sản phẩm", request, response);
                        }
                        case "delete" -> render("delete", "Xác nhận xoá sản phẩm", request, response);
                        case "view" -> render("view", "Chi tiết sản phẩm", request, response);
                    }
                }
                default -> error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        }
    }

    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        String token = request.getParameter("csrf");
        if (token == null || !token.equals(request.getSession().getAttribute("csrf"))) {
            error(403, "Phiên biểu mẫu không hợp lệ. Hãy mở lại trang và thử lại.", request, response);
            return;
        }
        try {
            switch (action(request, "")) {
                case "create", "edit" -> save(request, response);
                case "delete" -> {
                    if (!"yes".equals(request.getParameter("confirmed"))) {
                        error(400, "Bạn cần xác nhận trước khi xoá sản phẩm.", request, response);
                    } else if (productService.remove(id(request))) {
                        success("Đã xoá sản phẩm.", request, response);
                    } else {
                        error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
                    }
                }
                default -> error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        }
    }

    private void save(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean editing = "edit".equals(request.getParameter("action"));
        int productId = editing ? id(request) : 0;
        ProductForm form = new ProductForm(productId, request.getParameter("name"),
                request.getParameter("price"), request.getParameter("description"), request.getParameter("manufacturer"));
        Product product;
        try {
            product = form.toProduct();
        } catch (IllegalArgumentException e) {
            response.setStatus(400);
            request.setAttribute("form", form);
            request.setAttribute("errorMessage", e.getMessage());
            render("form", editing ? "Sửa sản phẩm" : "Thêm sản phẩm", request, response);
            return;
        }
        if (!editing) {
            productService.save(product);
            success("Đã thêm sản phẩm.", request, response);
        } else if (productService.update(productId, product)) {
            success("Đã cập nhật sản phẩm.", request, response);
        } else {
            error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
        }
    }

    private static void prepare(HttpServletRequest request, HttpServletResponse response)
            throws java.io.UnsupportedEncodingException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("X-Content-Type-Options", "nosniff");
        HttpSession session = request.getSession();
        synchronized (session) {
            if (session.getAttribute("csrf") == null)
                session.setAttribute("csrf", UUID.randomUUID().toString());
        }
    }

    private static String action(HttpServletRequest request, String fallback) {
        String action = request.getParameter("action");
        return action == null ? fallback : action;
    }

    private static int id(HttpServletRequest request) {
        int id = Integer.parseInt(request.getParameter("id"));
        if (id <= 0) throw new IllegalArgumentException("Invalid ID");
        return id;
    }

    private static void render(String view, String title, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", title);
        request.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(request, response);
    }

    private static void success(String message, HttpServletRequest request, HttpServletResponse response) {
        request.getSession().setAttribute("message", message);
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.setHeader("Location", request.getContextPath() + "/products");
    }

    private static void error(int status, String message, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("errorMessage", message);
        render("error", "Không thể thực hiện yêu cầu", request, response);
    }
}
```

### src/main/java/com/codegym/model/Product.java

```java
package com.codegym.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Đối tượng bất biến để dữ liệu trong Service không bị sửa từ bên ngoài. */
public final class Product {
    private final int id;
    private final String name;
    private final BigDecimal price;
    private final String description;
    private final String manufacturer;

    public Product(int id, String name, BigDecimal price, String description, String manufacturer) {
        if (id < 0) throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        this.id = id;
        this.name = required(name, "Tên sản phẩm");
        this.manufacturer = required(manufacturer, "Nhà sản xuất");
        this.description = description == null ? "" : description.strip();
        if (this.description.length() > 2000)
            throw new IllegalArgumentException("Mô tả tối đa 2000 ký tự.");
        if (price == null || price.signum() < 0 || price.compareTo(new BigDecimal("9999999999999.99")) > 0)
            throw new IllegalArgumentException("Giá phải từ 0 đến 9999999999999.99.");
        try {
            this.price = price.setScale(2, RoundingMode.UNNECESSARY);
        } catch (ArithmeticException e) {
            throw new IllegalArgumentException("Giá chỉ được có tối đa 2 chữ số thập phân.");
        }
    }

    private static String required(String text, String label) {
        String value = text == null ? "" : text.strip();
        if (value.isEmpty() || value.length() > 255)
            throw new IllegalArgumentException(label + " phải có từ 1 đến 255 ký tự.");
        return value;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public String getDescription() { return description; }
    public String getManufacturer() { return manufacturer; }
}
```

### src/main/java/com/codegym/service/ProductService.java

```java
package com.codegym.service;

import com.codegym.model.Product;
import java.util.List;

public interface ProductService {
    List<Product> findAll();
    Product findById(int id);
    /** Tự cấp ID cho sản phẩm có ID đầu vào bằng 0. */
    Product save(Product product);
    /** Trả về false nếu sản phẩm cần sửa không còn tồn tại. */
    boolean update(int id, Product product);
    boolean remove(int id);
    List<Product> searchByName(String keyword);
}
```

### src/main/java/com/codegym/service/ProductServiceImpl.java

```java
package com.codegym.service;

import com.codegym.model.Product;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Map tĩnh giả lập dữ liệu, dùng chung cho các phiên trong cùng ứng dụng. */
public class ProductServiceImpl implements ProductService {
    private static final Map<Integer, Product> products = new LinkedHashMap<>();
    private static int nextId = 6;

    static {
        products.put(1, new Product(1, "Bàn phím cơ", new BigDecimal("750000"), "Bàn phím có đèn nền và kết nối USB.", "KeyPro"));
        products.put(2, new Product(2, "Chuột không dây", new BigDecimal("250000"), "Chuột dùng kết nối Bluetooth.", "TechMouse"));
        products.put(3, new Product(3, "Màn hình 24 inch", new BigDecimal("3200000"), "Màn hình Full HD phục vụ học tập và làm việc.", "ViewMax"));
        products.put(4, new Product(4, "Tai nghe", new BigDecimal("450000"), "Tai nghe có micro tích hợp.", "SoundOne"));
        products.put(5, new Product(5, "Bàn phím không dây", new BigDecimal("550000"), "Bàn phím nhỏ gọn cho máy tính xách tay.", "KeyPro"));
    }

    @Override public List<Product> findAll() {
        synchronized (products) { return new ArrayList<>(products.values()); }
    }

    @Override public Product findById(int id) {
        synchronized (products) { return products.get(id); }
    }

    @Override public Product save(Product product) {
        if (product == null || product.getId() != 0)
            throw new IllegalArgumentException("Sản phẩm mới phải chưa có ID.");
        synchronized (products) {
            if (nextId == Integer.MAX_VALUE) throw new IllegalStateException("Đã hết ID sản phẩm.");
            Product saved = withId(nextId++, product);
            products.put(saved.getId(), saved);
            return saved;
        }
    }

    @Override public boolean update(int id, Product product) {
        if (product == null || product.getId() != id)
            throw new IllegalArgumentException("ID sản phẩm cập nhật không khớp.");
        synchronized (products) {
            if (!products.containsKey(id)) return false;
            products.put(id, product);
            return true;
        }
    }

    @Override public boolean remove(int id) {
        synchronized (products) { return products.remove(id) != null; }
    }

    @Override public List<Product> searchByName(String keyword) {
        String text = keyword == null ? "" : keyword.strip().toLowerCase(Locale.ROOT);
        return findAll().stream()
                .filter(product -> product.getName().toLowerCase(Locale.ROOT).contains(text))
                .toList();
    }

    private static Product withId(int id, Product product) {
        return new Product(id, product.getName(), product.getPrice(),
                product.getDescription(), product.getManufacturer());
    }
}
```

### src/main/webapp/assets/styles.css

```css
:root { font-family: Arial, sans-serif; color: #172b46; background: #f3f6fa; }
* { box-sizing: border-box; }
body { margin: 0; line-height: 1.6; }
a { color: #1b57b0; text-underline-offset: 3px; }
a:hover { color: #123e80; }
header { background: #173453; padding: 18px 0; }
.brand { color: white; font-size: 21px; font-weight: bold; text-decoration: none; }
.brand:hover { color: #dce9fa; }
.container { width: min(1200px, calc(100% - 32px)); margin: 0 auto; }
main { padding: 30px 0; }
.narrow { max-width: 650px; margin: 0 auto; }
h1 { font-size: 28px; line-height: 1.3; margin: 0 0 12px; }
.narrow h1 { margin-top: 18px; }
p { margin: 0 0 16px; }
.muted, footer { color: #576678; }
.toolbar { display: flex; justify-content: space-between; align-items: center; gap: 20px; margin-bottom: 20px; }
.toolbar p { margin: 0; }
.button, button { display: inline-block; border: 1px solid transparent; border-radius: 6px; background: #1b57b0; color: white; font: inherit; font-weight: bold; padding: 10px 16px; text-decoration: none; cursor: pointer; }
.button:hover, button:hover { color: white; background: #123e80; }
.secondary { color: #172b46; background: #e9eef5; }
.secondary:hover { color: #172b46; background: #d8e1ed; }
.danger { background: #b22b36; }
.danger:hover { background: #8f2029; }
.danger-link { color: #a52431; }
.search { display: flex; gap: 12px; align-items: center; margin-bottom: 20px; flex-wrap: wrap; }
.search label { margin: 0; }
.search input { flex: 1; min-width: 200px; }
.table-wrapper { overflow-x: auto; border: 1px solid #d4dde8; border-radius: 8px; background: white; }
table { border-collapse: collapse; width: 100%; min-width: 800px; }
th, td { text-align: left; padding: 14px 16px; border-bottom: 1px solid #e3e9f0; }
th { background: #eaf0f7; white-space: nowrap; }
tbody tr:last-child td { border-bottom: 0; }
td { overflow-wrap: anywhere; }
.number { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
.description { max-width: 270px; }
.actions { white-space: nowrap; }
.actions a + a { margin-left: 12px; }
.empty { text-align: center; color: #576678; padding: 32px; }
.card { padding: 24px; background: white; border: 1px solid #d4dde8; border-radius: 8px; }
label { display: block; font-weight: bold; margin: 12px 0 6px; }
input:not([type="hidden"]), textarea { width: 100%; border: 1px solid #8193aa; border-radius: 5px; padding: 10px 12px; font: inherit; }
textarea { resize: vertical; }
:focus-visible { outline: 3px solid #eeaa20; outline-offset: 3px; }
.form-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 24px; }
.notice, .error { padding: 12px 16px; border-radius: 5px; }
.notice { color: #185b3e; background: #e3f4eb; border: 1px solid #acd6bc; }
.error { color: #8d202b; background: #fce8eb; border: 1px solid #efbec5; }
dl { display: grid; grid-template-columns: 140px 1fr; gap: 10px 16px; }
dt { font-weight: bold; }
dd { margin: 0; overflow-wrap: anywhere; }
.multiline { white-space: pre-wrap; }
footer { padding-bottom: 24px; font-size: 14px; }
.visually-hidden { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }
@media (max-width: 600px) {
    .toolbar { align-items: flex-start; flex-direction: column; }
    h1 { font-size: 24px; }
    .card { padding: 18px; }
    .search { align-items: stretch; flex-direction: column; }
    .search input { min-width: 0; }
    dl { grid-template-columns: 1fr; gap: 4px; }
    dd { margin-bottom: 12px; }
}
```

### src/main/webapp/WEB-INF/views/delete.jsp

```jsp
<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<div class="narrow">
    <h1>Xác nhận xoá sản phẩm</h1>
    <div class="card">
        <p>Bạn có muốn xoá sản phẩm <strong><c:out value="${product.name}"/></strong> không?</p>
        <dl><dt>ID</dt><dd>${product.id}</dd><dt>Giá (VNĐ)</dt><dd><c:out value="${product.price}"/></dd><dt>Nhà sản xuất</dt><dd><c:out value="${product.manufacturer}"/></dd></dl>
        <form action="<c:out value='${productsUrl}'/>" method="post">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="${product.id}">
            <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
            <div class="form-actions"><button class="danger" type="submit" name="confirmed" value="yes">Xác nhận xoá</button><a class="button secondary" href="<c:out value='${productsUrl}'/>">Huỷ</a></div>
        </form>
    </div>
</div>
<%@ include file="fragments/footer.jspf" %>
```

### src/main/webapp/WEB-INF/views/error.jsp

```jsp
<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<div class="narrow">
    <h1>Không thể thực hiện yêu cầu</h1>
    <p class="error" role="alert"><c:out value="${errorMessage}"/></p>
    <a class="button" href="<c:out value='${productsUrl}'/>">Về danh sách sản phẩm</a>
</div>
<%@ include file="fragments/footer.jspf" %>
```

### src/main/webapp/WEB-INF/views/form.jsp

```jsp
<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<div class="narrow">
    <a href="<c:out value='${productsUrl}'/>">← Danh sách sản phẩm</a>
    <h1><c:out value="${pageTitle}"/></h1>
    <c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
    <form class="card" action="<c:out value='${productsUrl}'/>" method="post">
        <input type="hidden" name="action" value="${form.id == 0 ? 'create' : 'edit'}">
        <input type="hidden" name="id" value="${form.id}">
        <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
        <c:if test="${form.id > 0}"><p class="muted">Mã sản phẩm: ${form.id}</p></c:if>
        <label for="name">Tên sản phẩm</label>
        <input id="name" name="name" type="text" maxlength="255" required value="<c:out value='${form.name}'/>">
        <label for="price">Giá (VNĐ)</label>
        <input id="price" name="price" type="number" min="0" max="9999999999999.99" step="0.01" required value="<c:out value='${form.price}'/>">
        <label for="manufacturer">Nhà sản xuất</label>
        <input id="manufacturer" name="manufacturer" type="text" maxlength="255" required value="<c:out value='${form.manufacturer}'/>">
        <label for="description">Mô tả</label>
        <textarea id="description" name="description" rows="5" maxlength="2000"><c:out value="${form.description}"/></textarea>
        <div class="form-actions"><button type="submit">Lưu sản phẩm</button><a class="button secondary" href="<c:out value='${productsUrl}'/>">Huỷ</a></div>
    </form>
</div>
<%@ include file="fragments/footer.jspf" %>
```

### src/main/webapp/WEB-INF/views/fragments/footer.jspf

```jsp
<%@ page pageEncoding="UTF-8" %>
</main>
<footer class="container">Ứng dụng MVC · DTC245200382</footer>
</body>
</html>
```

### src/main/webapp/WEB-INF/views/fragments/header.jspf

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:url value="/products" var="productsUrl"/>
<c:url value="/assets/styles.css" var="stylesUrl"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${pageTitle}"/></title>
    <link rel="stylesheet" href="<c:out value='${stylesUrl}'/>">
</head>
<body>
<header><div class="container"><a class="brand" href="<c:out value='${productsUrl}'/>">Quản lý sản phẩm</a></div></header>
<main class="container">
```

### src/main/webapp/WEB-INF/views/list.jsp

```jsp
<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<c:url value="/products" var="createUrl"><c:param name="action" value="create"/></c:url>
<div class="toolbar">
    <div><h1>Danh sách sản phẩm</h1><p class="muted">Quản lý thông tin và tìm kiếm sản phẩm theo tên.</p></div>
    <a class="button" href="<c:out value='${createUrl}'/>">+ Thêm sản phẩm</a>
</div>
<c:if test="${not empty message}"><p class="notice" role="status"><c:out value="${message}"/></p></c:if>
<form class="search" method="get" action="<c:out value='${productsUrl}'/>">
    <input type="hidden" name="action" value="search">
    <label for="keyword">Tên sản phẩm</label>
    <input id="keyword" name="keyword" type="search" placeholder="Nhập một phần tên sản phẩm" value="<c:out value='${keyword}'/>">
    <button type="submit">Tìm kiếm</button>
    <a href="<c:out value='${productsUrl}'/>">Xem tất cả</a>
</form>
<c:if test="${not empty keyword}"><p>Kết quả cho: <strong><c:out value="${keyword}"/></strong></p></c:if>
<div class="table-wrapper">
    <table>
        <caption class="visually-hidden">Danh sách sản phẩm và các thao tác quản lý</caption>
        <thead><tr><th scope="col">ID</th><th scope="col">Tên sản phẩm</th><th scope="col" class="number">Giá (VNĐ)</th><th scope="col">Mô tả</th><th scope="col">Nhà sản xuất</th><th scope="col">Thao tác</th></tr></thead>
        <tbody>
        <c:choose>
            <c:when test="${empty products}"><tr><td class="empty" colspan="6">Không có sản phẩm phù hợp.</td></tr></c:when>
            <c:otherwise>
                <c:forEach items="${products}" var="product">
                    <c:url value="/products" var="viewUrl"><c:param name="action" value="view"/><c:param name="id" value="${product.id}"/></c:url>
                    <c:url value="/products" var="editUrl"><c:param name="action" value="edit"/><c:param name="id" value="${product.id}"/></c:url>
                    <c:url value="/products" var="deleteUrl"><c:param name="action" value="delete"/><c:param name="id" value="${product.id}"/></c:url>
                    <tr data-product-id="${product.id}">
                        <td>${product.id}</td>
                        <td><a href="<c:out value='${viewUrl}'/>"><c:out value="${product.name}"/></a></td>
                        <td class="number"><c:out value="${product.price}"/></td>
                        <td class="description"><c:out value="${product.description}"/></td>
                        <td><c:out value="${product.manufacturer}"/></td>
                        <td class="actions"><a href="<c:out value='${viewUrl}'/>">Xem</a><a href="<c:out value='${editUrl}'/>">Sửa</a><a class="danger-link" href="<c:out value='${deleteUrl}'/>">Xoá</a></td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>
<%@ include file="fragments/footer.jspf" %>
```

### src/main/webapp/WEB-INF/views/view.jsp

```jsp
<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<c:url value="/products" var="editUrl"><c:param name="action" value="edit"/><c:param name="id" value="${product.id}"/></c:url>
<c:url value="/products" var="deleteUrl"><c:param name="action" value="delete"/><c:param name="id" value="${product.id}"/></c:url>
<div class="narrow">
    <a href="<c:out value='${productsUrl}'/>">← Danh sách sản phẩm</a>
    <h1>Chi tiết sản phẩm</h1>
    <div class="card">
        <dl>
            <dt>ID</dt><dd>${product.id}</dd>
            <dt>Tên sản phẩm</dt><dd><c:out value="${product.name}"/></dd>
            <dt>Giá (VNĐ)</dt><dd><c:out value="${product.price}"/></dd>
            <dt>Nhà sản xuất</dt><dd><c:out value="${product.manufacturer}"/></dd>
            <dt>Mô tả</dt><dd class="multiline"><c:out value="${product.description}"/></dd>
        </dl>
        <div class="form-actions"><a class="button" href="<c:out value='${editUrl}'/>">Sửa sản phẩm</a><a class="button danger" href="<c:out value='${deleteUrl}'/>">Xoá sản phẩm</a></div>
    </div>
</div>
<%@ include file="fragments/footer.jspf" %>
```

### src/main/webapp/WEB-INF/web.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>Quản lý sản phẩm MVC</display-name>
    <servlet>
        <servlet-name>ProductServlet</servlet-name>
        <servlet-class>com.codegym.controller.ProductServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>ProductServlet</servlet-name>
        <url-pattern>/products</url-pattern>
    </servlet-mapping>
    <welcome-file-list><welcome-file>products</welcome-file></welcome-file-list>
    <session-config>
        <session-timeout>30</session-timeout>
        <cookie-config><http-only>true</http-only></cookie-config>
    </session-config>
</web-app>
```

### src/test/java/com/codegym/service/ProductServiceTest.java

```java
package com.codegym.service;

import com.codegym.controller.ProductForm;
import com.codegym.model.Product;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ProductServiceTest {
    private final ProductService service = new ProductServiceImpl();

    private Product draft(String name) {
        return new Product(0, name, new BigDecimal("123.45"), "Mô tả", "Nhà sản xuất");
    }

    @Test void createsReadsUpdatesAndDeletes() {
        Product saved = service.save(draft("Sản phẩm kiểm thử"));
        try {
            assertTrue(saved.getId() > 0);
            assertEquals("Sản phẩm kiểm thử", service.findById(saved.getId()).getName());
            Product changed = new Product(saved.getId(), "Đã sửa", new BigDecimal("99.10"), "Mô tả mới", "Hãng mới");
            assertTrue(service.update(saved.getId(), changed));
            assertEquals(new BigDecimal("99.10"), service.findById(saved.getId()).getPrice());
            assertTrue(service.remove(saved.getId()));
            assertNull(service.findById(saved.getId()));
        } finally { service.remove(saved.getId()); }
    }

    @Test void dataIsSharedBetweenServiceInstances() {
        Product saved = service.save(draft("Dùng chung"));
        try { assertEquals("Dùng chung", new ProductServiceImpl().findById(saved.getId()).getName()); }
        finally { service.remove(saved.getId()); }
    }

    @Test void searchesPartialNamesIgnoringCaseAndSpaces() {
        assertEquals(2, service.searchByName("  BÀN PHÍM ").size());
        assertTrue(service.searchByName("kết nối USB").isEmpty());
        assertEquals(service.findAll().size(), service.searchByName(" \t ").size());
        assertEquals(service.findAll().size(), service.searchByName(null).size());
    }

    @Test void idsAreNotReusedAndExistingProductsCannotBeOverwrittenBySave() {
        Product first = service.save(draft("First"));
        service.remove(first.getId());
        Product second = service.save(draft("Second"));
        try {
            assertTrue(second.getId() > first.getId());
            assertThrows(IllegalArgumentException.class, () -> service.save(second));
            assertEquals("Second", service.findById(second.getId()).getName());
        } finally { service.remove(second.getId()); }
    }

    @Test void listIsASnapshotAndCannotRemoveStoredProducts() {
        List<Product> snapshot = service.findAll();
        int count = snapshot.size();
        snapshot.clear();
        assertEquals(count, service.findAll().size());
    }

    @Test void concurrentCreatesHaveUniqueIds() throws Exception {
        var executor = Executors.newFixedThreadPool(8);
        List<Future<Product>> futures = new ArrayList<>();
        List<Product> saved = new ArrayList<>();
        try {
            for (int i = 0; i < 40; i++) futures.add(executor.submit(() -> service.save(draft("Concurrent"))));
            for (Future<Product> future : futures) saved.add(future.get());
            assertEquals(40, new HashSet<>(saved.stream().map(Product::getId).toList()).size());
        } finally {
            executor.shutdown();
            executor.awaitTermination(5, java.util.concurrent.TimeUnit.SECONDS);
            for (Future<Product> future : futures) if (future.isDone() && !future.isCancelled()) {
                service.remove(future.get().getId());
            }
        }
    }

    @Test void staleUpdateDoesNotRecreateDeletedProduct() {
        Product saved = service.save(draft("Stale"));
        service.remove(saved.getId());
        assertFalse(service.update(saved.getId(), saved));
        assertNull(service.findById(saved.getId()));
        assertFalse(service.remove(saved.getId()));
    }

    @Test void validatesMoneyWithoutRounding() {
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", new BigDecimal("-1"), "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", new BigDecimal("1.001"), "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", new BigDecimal("10000000000000"), "", "B"));
        assertEquals(new BigDecimal("0.00"), new Product(0, "A", BigDecimal.ZERO, "", "B").getPrice());
    }

    @Test void validatesRequiredTextAndDescriptionLength() {
        assertThrows(IllegalArgumentException.class, () -> new Product(0, " ", BigDecimal.ONE, "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", BigDecimal.ONE, "", " "));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A".repeat(256), BigDecimal.ONE, "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", BigDecimal.ONE, "x".repeat(2001), "B"));
    }

    @Test void formPreservesDraftAndParsesDecimalPrice() {
        ProductForm valid = new ProductForm(0, "  Bàn phím  ", " 99.10 ", "Mô tả", " KeyPro ");
        assertEquals("Bàn phím", valid.toProduct().getName());
        assertEquals(new BigDecimal("99.10"), valid.toProduct().getPrice());
        ProductForm invalid = new ProductForm(0, "Tên gốc", "1e3", "Nội dung gốc", "Hãng");
        assertEquals("Tên gốc", invalid.getName());
        assertEquals("Nội dung gốc", invalid.getDescription());
        assertThrows(IllegalArgumentException.class, invalid::toProduct);
    }
}
```
