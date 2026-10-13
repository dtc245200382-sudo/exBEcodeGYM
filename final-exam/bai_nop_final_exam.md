# Bài kiểm tra cuối module: Quản lý sản phẩm với JSP và Servlet

Mã số sinh viên: **DTC245200382**
Tệp nộp: **DTC245200382_FinalExam.zip**
Ngày hoàn thành và kiểm thử: **13/10/2026**

Tài liệu này gom yêu cầu, hướng dẫn chạy, kết quả kiểm thử và toàn bộ mã nguồn vào một file. ZIP đi kèm chứa dự án Maven đầy đủ và SQL để giảng viên giải nén, biên dịch và chạy trên Apache Tomcat.

## 1. Các chức năng đã thực hiện

| Yêu cầu | Cách thực hiện |
| --- | --- |
| Danh sách sản phẩm | Servlet lấy dữ liệu từ MySQL qua JDBC; JSP hiển thị bảng ID, tên, giá, số lượng và thao tác |
| Thêm mới | Form tên, giá, số lượng; kiểm tra phía trình duyệt và phía server; tự sinh ID |
| Sửa | Mở form chứa dữ liệu hiện có theo ID; cập nhật bằng PreparedStatement |
| Xoá có xác nhận | Nút Xoá mở trang xác nhận; chỉ khi bấm Xác nhận xoá mới gửi POST xoá dữ liệu; có nút Huỷ |
| Cơ sở dữ liệu | `product_management_db.products` với `id INT PRIMARY KEY AUTO_INCREMENT`, `name VARCHAR(255)`, `price DECIMAL(15,2)`, `quantity INT` |
| Dữ liệu mẫu | 3 sản phẩm trong `database.sql`; chạy lại SQL không nhân đôi dữ liệu mẫu |
| Chạy trên Tomcat | Maven tạo `product-management.war`; Servlet 6.0 dùng namespace `jakarta.servlet` |

Giá tiền dùng `BigDecimal` trong Java và `DECIMAL(15,2)` trong MySQL. Tên không được trống; giá và số lượng không âm; giá tối đa 2 chữ số thập phân; số lượng là số nguyên. Khi dữ liệu không hợp lệ, form giữ lại thông tin đã nhập và hiển thị lỗi từng trường.

Các lệnh ghi dùng POST và mã CSRF của phiên. Sau khi thành công, server chuyển về danh sách bằng HTTP 303 để tải lại trang không gửi lại lệnh INSERT. Tên sản phẩm được escape trước khi hiển thị trong HTML; SQL dùng tham số, không ghép chuỗi dữ liệu nhập vào câu lệnh.

## 2. Cấu trúc dự án

```text
DTC245200382_FinalExam.zip
├── bai_nop_final_exam.md
└── product-management/
    ├── .gitignore
    ├── pom.xml
    ├── database.sql
    ├── scripts/smoke-test.ps1
    └── src/
        ├── main/
        │   ├── java/com/codegym/products/
        │   │   ├── model/Product.java
        │   │   ├── dao/Database.java
        │   │   ├── dao/ProductDAO.java
        │   │   └── web/{ProductServlet,ProductForm,Html}.java
        │   └── webapp/
        │       ├── assets/styles.css
        │       └── WEB-INF/
        │           ├── web.xml
        │           └── views/{list,form,delete,error}.jsp
        └── test/java/com/codegym/products/web/ProductFormTest.java
```

Luồng xử lý: trình duyệt → `ProductServlet` → `ProductDAO` → MySQL → JSP. JSP chỉ hiển thị dữ liệu, không mở kết nối hoặc chạy SQL. Các JSP đặt trong `WEB-INF` để người dùng truy cập qua Servlet.

## 3. Hướng dẫn chạy

### Môi trường

- JDK **17 trở lên**, Maven **3.9 trở lên**.
- Apache Tomcat **10.1.x**, MySQL **8.4**.
- Không triển khai WAR này lên Tomcat 9 vì dự án dùng `jakarta.servlet`.

### Tạo cơ sở dữ liệu

Giải nén ZIP. Trong MySQL Workbench, mở `product-management/database.sql` và chạy toàn bộ file. SQL tạo database, bảng và dữ liệu mẫu; không xoá database đang có.

### Cấu hình JDBC

Ứng dụng đọc ba biến môi trường sau khi Tomcat khởi động:

| Biến | Giá trị mặc định |
| --- | --- |
| `PRODUCT_DB_URL` | `jdbc:mysql://localhost:3306/product_management_db?characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh` |
| `PRODUCT_DB_USER` | `root` |
| `PRODUCT_DB_PASSWORD` | Chuỗi rỗng; đặt mật khẩu phù hợp với MySQL của bạn |

Ví dụ PowerShell, thay đường dẫn và thông tin kết nối bằng cấu hình trên máy của bạn:

```powershell
$env:JAVA_HOME = 'C:\Java\jdk-17'
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
$tomcatPath = 'C:\tools\apache-tomcat-10.1'
$env:PRODUCT_DB_URL = 'jdbc:mysql://localhost:3306/product_management_db?characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh'
$env:PRODUCT_DB_USER = 'root'
$env:PRODUCT_DB_PASSWORD = 'MAT_KHAU_MYSQL_CUA_BAN'

Set-Location .\product-management
mvn clean package
Copy-Item .\target\product-management.war "$tomcatPath\webapps\product-management.war"
& "$tomcatPath\bin\catalina.bat" run
```

Mở **http://localhost:8080/product-management/**. Nếu Tomcat dùng cổng khác, thay `8080` bằng cổng đó. Đặt biến môi trường trong chính terminal dùng để chạy Tomcat; nếu chạy Tomcat từ IDE, cấu hình các biến trong Run Configuration và khởi động lại Tomcat.

Nếu danh sách báo lỗi kết nối, kiểm tra MySQL đã chạy, SQL đã được import, URL/cổng/user/password đúng. Với MySQL cục bộ không dùng TLS và báo `Public Key Retrieval is not allowed`, có thể thêm `&allowPublicKeyRetrieval=true&useSSL=false` vào URL của môi trường thực hành cục bộ.

### Kiểm thử

```powershell
# Chạy JUnit; không cần khởi động MySQL cho các bài kiểm thử đầu vào.
mvn test

# Chạy kiểm tra HTTP sau khi đã import SQL và khởi động Tomcat.
powershell -ExecutionPolicy Bypass -File .\scripts\smoke-test.ps1 `
    -BaseUrl 'http://localhost:8080/product-management'
```

Script HTTP tạo sản phẩm có tên riêng cho lượt kiểm thử rồi xoá chính sản phẩm đó; không xoá các sản phẩm khác. Các file Java, JSP và SQL đều dùng UTF-8; script PowerShell có BOM để PowerShell 5 đọc đúng tiếng Việt.

## 4. Kết quả kiểm thử thực tế

Đã biên dịch bằng JDK 17.0.20.1 và Maven 3.9.9, triển khai WAR lên Apache Tomcat 10.1.61, kết nối MySQL 8.4.11 qua JDBC. Môi trường kiểm thử dùng Tomcat tại `127.0.0.1:18780` và MySQL riêng tại `127.0.0.1:13316`; đây là các cổng thử nghiệm, cấu hình chạy thông thường ở mục trên dùng 8080/3306.

- **7 kiểm thử JUnit đạt**, không có lỗi hoặc bài bị bỏ qua.
- **31 kiểm tra HTTP đạt**, bao gồm thêm/sửa/xoá thật trên MySQL, xác nhận xoá, dữ liệu tiếng Việt, giá thập phân, lỗi đầu vào, ID không hợp lệ, form sửa cũ và token CSRF.
- Import SQL lần thứ hai vẫn có đúng **3 sản phẩm mẫu**, không nhân đôi bản ghi. Sau khi kiểm thử, các sản phẩm thử đã được dọn; dữ liệu mẫu vẫn còn.
- Kiểm tra UI qua nội dung HTML trả về và luồng HTTP; chưa thực hiện kiểm tra trực quan bằng ảnh chụp trình duyệt.

Phần dưới chứa trích xuất log kiểm thử và toàn bộ nguồn để thuận tiện đọc một file.

## 5. Nguồn tham khảo và hỗ trợ

Mã nguồn được tạo cho bài tập này với hỗ trợ của ChatGPT/Codex. Cấu trúc Maven/Jakarta và hàm escape HTML được điều chỉnh từ bài iNotes trước đó trong cùng kho bài tập. Không chép dự án sản phẩm từ kho bên ngoài. Tài liệu API tham khảo:

- [Apache Tomcat 10.1 — Servlet 6.0 và JSP 3.1](https://tomcat.apache.org/tomcat-10.1-doc/index.html).
- [MySQL Connector/J — Thực thi SQL qua JDBC](https://dev.mysql.com/doc/connector-j/en/connector-j-usagenotes-statements.html).

## 6. Log kiểm thử

### final-exam-build.log

```text
[INFO] Scanning for projects...
[INFO]
[INFO] -------------------< com.codegym:product-management >-------------------
[INFO] Building product-management 1.0-SNAPSHOT
[INFO]   from pom.xml
[INFO] --------------------------------[ war ]---------------------------------
[INFO]
[INFO] --- clean:3.2.0:clean (default-clean) @ product-management ---
[INFO]
[INFO] --- resources:3.3.1:resources (default-resources) @ product-management ---
[INFO] skip non existing resourceDirectory E:\BaitapinternCodeGYM\exBEcodeGYM\final-exam\product-management\src\main\resources
[INFO]
[INFO] --- compiler:3.13.0:compile (default-compile) @ product-management ---
[INFO] Recompiling the module because of changed source code.
[INFO] Compiling 6 source files with javac [debug release 17] to target\classes
[INFO]
[INFO] --- resources:3.3.1:testResources (default-testResources) @ product-management ---
[INFO] skip non existing resourceDirectory E:\BaitapinternCodeGYM\exBEcodeGYM\final-exam\product-management\src\test\resources
[INFO]
[INFO] --- compiler:3.13.0:testCompile (default-testCompile) @ product-management ---
[INFO] Recompiling the module because of changed dependency.
[INFO] Compiling 1 source file with javac [debug release 17] to target\test-classes
[INFO]
[INFO] --- surefire:3.2.5:test (default-test) @ product-management ---
[INFO] Using auto detected provider org.apache.maven.surefire.junitplatform.JUnitPlatformProvider
[INFO]
[INFO] -------------------------------------------------------
[INFO]  T E S T S
[INFO] -------------------------------------------------------
[INFO] Running com.codegym.products.web.ProductFormTest
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.052 s -- in com.codegym.products.web.ProductFormTest
[INFO]
[INFO] Results:
[INFO]
[INFO] Tests run: 7, Failures: 0, Errors: 0, Skipped: 0
[INFO]
[INFO]
[INFO] --- war:3.4.0:war (default-war) @ product-management ---
[INFO] Packaging webapp
[INFO] Assembling webapp [product-management] in [E:\BaitapinternCodeGYM\exBEcodeGYM\final-exam\product-management\target\product-management]
[INFO] Processing war project
[INFO] Copying webapp resources [E:\BaitapinternCodeGYM\exBEcodeGYM\final-exam\product-management\src\main\webapp]
[INFO] Building war: E:\BaitapinternCodeGYM\exBEcodeGYM\final-exam\product-management\target\product-management.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  2.937 s
[INFO] Finished at: 2026-10-13T18:14:50+07:00
[INFO] ------------------------------------------------------------------------

```

### final-exam-http-verification.txt

```text
PASS: List page loads through Servlet and JSP
PASS: Application root uses the welcome servlet
PASS: Stylesheet and responsive rules are available
PASS: Add form includes a session token
PASS: Missing CSRF token is rejected
PASS: Invalid CSRF token is rejected
PASS: Server validates all three input fields
PASS: Invalid decimal price does not discard the typed name
PASS: Price and quantity overflow are rejected
PASS: Create uses Post/Redirect/Get
PASS: Created product and success message appear in the list
PASS: Refreshing the list does not create another product
PASS: Edit form is prefilled from MySQL
PASS: Updating a product succeeds
PASS: Unicode, apostrophes and decimal money survive the JDBC round trip
PASS: Product name is escaped in HTML
PASS: Saving unchanged values is accepted
PASS: Invalid update is rejected
PASS: Invalid update leaves the stored product unchanged
PASS: Delete opens a confirmation page
PASS: Opening or cancelling confirmation does not delete the product
PASS: Deletion without explicit confirmation is rejected
PASS: A GET request cannot delete data
PASS: Confirmed deletion succeeds
PASS: Deleted product disappears from the list
PASS: A deleted product cannot be edited
PASS: Submitting a stale edit does not recreate the product
PASS: Repeated delete reports a missing product
PASS: Malformed product ID is rejected
PASS: JSP views are protected behind WEB-INF
PASS: Another session reads the same database-backed list
RESULT: 31 HTTP checks passed

```

### final-exam-database-verification.txt

```text
mysql_version
8.4.11
remaining_products
3
Table	Create Table
products	CREATE TABLE `products` (\n  `id` int NOT NULL AUTO_INCREMENT,\n  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,\n  `price` decimal(15,2) NOT NULL,\n  `quantity` int NOT NULL,\n  PRIMARY KEY (`id`),\n  CONSTRAINT `chk_product_name` CHECK ((char_length(trim(`name`)) > 0)),\n  CONSTRAINT `chk_product_price` CHECK ((`price` >= 0)),\n  CONSTRAINT `chk_product_quantity` CHECK ((`quantity` >= 0))\n) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci

```

## 7. Toàn bộ mã nguồn

### .gitignore

```text
/target/
/.idea/
*.iml
*.log


```

### database.sql

```sql
-- Chạy toàn bộ file trong MySQL Workbench trước khi mở ứng dụng.
CREATE DATABASE IF NOT EXISTS product_management_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE product_management_db;

CREATE TABLE IF NOT EXISTS products (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(15, 2) NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT chk_product_name CHECK (CHAR_LENGTH(TRIM(name)) > 0),
    CONSTRAINT chk_product_price CHECK (price >= 0),
    CONSTRAINT chk_product_quantity CHECK (quantity >= 0)
) ENGINE=InnoDB;

-- Dữ liệu mẫu chỉ được thêm khi bảng đang trống; không ghi đè dữ liệu đã có.
INSERT INTO products (name, price, quantity)
SELECT seed.name, seed.price, seed.quantity
FROM (
    SELECT 'Bàn phím cơ' AS name, 750000.00 AS price, 12 AS quantity
    UNION ALL SELECT 'Chuột không dây', 250000.00, 20
    UNION ALL SELECT 'Màn hình 24 inch', 3200000.00, 5
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM products);

SELECT id, name, price, quantity FROM products ORDER BY id;

```

### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>product-management</artifactId>
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
            <groupId>com.mysql</groupId>
            <artifactId>mysql-connector-j</artifactId>
            <version>26.7.0</version>
        </dependency>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.11.4</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <finalName>product-management</finalName>
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
param([string]$BaseUrl = 'http://localhost:8080/product-management')
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
            [pscustomobject]@{
                Status = [int]$response.StatusCode
                Body = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
                Location = [string]$response.Headers.Location
            }
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
    foreach ($row in [regex]::Matches($Body, '(?s)<tr>.*?</tr>')) {
        if ($row.Value.Contains($Name)) {
            $match = [regex]::Match($row.Value, 'action=edit&amp;id=(\d+)')
            if ($match.Success) { return [int]$match.Groups[1].Value }
        }
    }
    throw "Product not found: $Name"
}

try {
    $list = Send-Request GET '/products'
    Check ($list.Status -eq 200 -and $list.Body.Contains('Danh sách sản phẩm')) 'List page loads through Servlet and JSP'
    $root = Send-Request GET '/'
    Check ($root.Status -eq 200 -and $root.Body.Contains('Danh sách sản phẩm')) 'Application root uses the welcome servlet'
    $css = Send-Request GET '/assets/styles.css'
    Check ($css.Status -eq 200 -and $css.Body.Contains('@media')) 'Stylesheet and responsive rules are available'
    $form = Send-Request GET '/products?action=create'
    $csrfMatch = [regex]::Match($form.Body, 'name="csrf" value="([^"]+)"')
    Check ($form.Status -eq 200 -and $csrfMatch.Success) 'Add form includes a session token'
    $csrf = $csrfMatch.Groups[1].Value

    $forbidden = Send-Request POST '/products' @{action='create'; name='Must not be saved'; price='1'; quantity='1'}
    Check ($forbidden.Status -eq 403) 'Missing CSRF token is rejected'
    $forbidden = Send-Request POST '/products' @{action='create'; csrf='wrong'; name='Must not be saved'; price='1'; quantity='1'}
    Check ($forbidden.Status -eq 403) 'Invalid CSRF token is rejected'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=''; price='-1'; quantity='1.5'}
    Check ($invalid.Status -eq 400 -and $invalid.Body.Contains('Tên sản phẩm phải') -and $invalid.Body.Contains('Giá phải') -and $invalid.Body.Contains('Số lượng phải')) 'Server validates all three input fields'
    $draft = 'Giữ lại nội dung đã nhập'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=$draft; price='1.001'; quantity='2'}
    Check ($invalid.Status -eq 400 -and $invalid.Body.Contains($draft)) 'Invalid decimal price does not discard the typed name'
    $invalid = Send-Request POST '/products' @{action='create'; csrf=$csrf; name='A'; price='10000000000000'; quantity='2147483648'}
    Check ($invalid.Status -eq 400) 'Price and quantity overflow are rejected'

    $suffix = [Guid]::NewGuid().ToString('N').Substring(0, 10)
    $originalName = "Sản phẩm thử nghiệm $suffix"
    $created = Send-Request POST '/products' @{action='create'; csrf=$csrf; name=$originalName; price='12345.67'; quantity='7'}
    Check ($created.Status -eq 303 -and $created.Location.EndsWith('/products')) 'Create uses Post/Redirect/Get'
    $list = Send-Request GET '/products'
    $productId = Find-ProductId $list.Body $originalName
    $createdIds.Add($productId)
    Check ($list.Body.Contains('12345.67') -and $list.Body.Contains('Đã thêm sản phẩm.')) 'Created product and success message appear in the list'
    $refreshed = Send-Request GET '/products'
    Check (([regex]::Matches($refreshed.Body, [regex]::Escape($originalName))).Count -eq 1) 'Refreshing the list does not create another product'
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Status -eq 200 -and $edit.Body.Contains($originalName) -and $edit.Body.Contains('value="12345.67"') -and $edit.Body.Contains('value="7"')) 'Edit form is prefilled from MySQL'

    $changedName = "Đã sửa $suffix <script>alert(1)</script> ' OR 1=1 --"
    $escapedName = $changedName.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;').Replace('"','&quot;').Replace("'",'&#39;')
    $updated = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name=$changedName; price='99.10'; quantity='0'}
    Check ($updated.Status -eq 303) 'Updating a product succeeds'
    $list = Send-Request GET '/products'
    Check ($list.Body.Contains($escapedName) -and $list.Body.Contains('99.10')) 'Unicode, apostrophes and decimal money survive the JDBC round trip'
    Check (-not $list.Body.Contains('<script>alert(1)</script>')) 'Product name is escaped in HTML'
    $again = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name=$changedName; price='99.10'; quantity='0'}
    Check ($again.Status -eq 303) 'Saving unchanged values is accepted'
    $invalid = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name=''; price='-9'; quantity='-1'}
    Check ($invalid.Status -eq 400) 'Invalid update is rejected'
    $edit = Send-Request GET "/products?action=edit&id=$productId"
    Check ($edit.Body.Contains($escapedName) -and $edit.Body.Contains('value="99.10"')) 'Invalid update leaves the stored product unchanged'

    $confirmation = Send-Request GET "/products?action=confirm-delete&id=$productId"
    Check ($confirmation.Status -eq 200 -and $confirmation.Body.Contains('Xác nhận xoá') -and $confirmation.Body.Contains('name="confirmed" value="yes"')) 'Delete opens a confirmation page'
    $list = Send-Request GET '/products'
    Check ($list.Body.Contains($escapedName)) 'Opening or cancelling confirmation does not delete the product'
    $unconfirmed = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId}
    Check ($unconfirmed.Status -eq 400) 'Deletion without explicit confirmation is rejected'
    $getDelete = Send-Request GET "/products?action=delete&id=$productId"
    Check ($getDelete.Status -eq 400) 'A GET request cannot delete data'
    $deleted = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId; confirmed='yes'}
    Check ($deleted.Status -eq 303) 'Confirmed deletion succeeds'
    $list = Send-Request GET '/products'
    Check (-not $list.Body.Contains($escapedName)) 'Deleted product disappears from the list'
    $missing = Send-Request GET "/products?action=edit&id=$productId"
    Check ($missing.Status -eq 404) 'A deleted product cannot be edited'
    $stale = Send-Request POST '/products' @{action='update'; csrf=$csrf; id=$productId; name='Stale'; price='1'; quantity='1'}
    Check ($stale.Status -eq 404) 'Submitting a stale edit does not recreate the product'
    $missing = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$productId; confirmed='yes'}
    Check ($missing.Status -eq 404) 'Repeated delete reports a missing product'
    $badId = Send-Request GET '/products?action=edit&id=not-an-id'
    Check ($badId.Status -eq 400) 'Malformed product ID is rejected'
    $privateView = Send-Request GET '/WEB-INF/views/list.jsp'
    Check ($privateView.Status -eq 404) 'JSP views are protected behind WEB-INF'
    $newSession = [System.Net.Http.HttpClient]::new()
    try {
        $freshList = $newSession.GetStringAsync("$BaseUrl/products").GetAwaiter().GetResult()
        Check ($freshList.Contains('Danh sách sản phẩm')) 'Another session reads the same database-backed list'
    } finally { $newSession.Dispose() }
    Write-Output "RESULT: $($checks.Count) HTTP checks passed"
} finally {
    # Chỉ dọn bản ghi do lượt kiểm thử này tạo, không xoá dữ liệu mẫu hay sản phẩm khác.
    foreach ($createdId in $createdIds) {
        try { $null = Send-Request POST '/products' @{action='delete'; csrf=$csrf; id=$createdId; confirmed='yes'} } catch { }
    }
    $client.Dispose()
}

```

### src/main/java/com/codegym/products/dao/Database.java

```java
package com.codegym.products.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Database {
    private final String url;
    private final String user;
    private final String password;

    public Database() {
        url = environment("PRODUCT_DB_URL",
                "jdbc:mysql://localhost:3306/product_management_db?characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh");
        user = environment("PRODUCT_DB_USER", "root");
        password = environment("PRODUCT_DB_PASSWORD", "");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("MySQL Connector/J is missing", e);
        }
    }

    private static String environment(String name, String fallback) {
        String value = System.getenv(name);
        return value == null ? fallback : value;
    }

    public Connection connect() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}

```

### src/main/java/com/codegym/products/dao/ProductDAO.java

```java
package com.codegym.products.dao;

import com.codegym.products.model.Product;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ProductDAO {
    private final Database database;

    public ProductDAO(Database database) { this.database = database; }

    public List<Product> findAll() throws SQLException {
        List<Product> products = new ArrayList<>();
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT id, name, price, quantity FROM products ORDER BY id");
             ResultSet rows = statement.executeQuery()) {
            while (rows.next()) products.add(read(rows));
        }
        return products;
    }

    public Optional<Product> findById(int id) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT id, name, price, quantity FROM products WHERE id = ?")) {
            statement.setInt(1, id);
            try (ResultSet rows = statement.executeQuery()) {
                return rows.next() ? Optional.of(read(rows)) : Optional.empty();
            }
        }
    }

    public int insert(Product product) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "INSERT INTO products(name, price, quantity) VALUES (?, ?, ?)",
                     Statement.RETURN_GENERATED_KEYS)) {
            bind(statement, product);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Missing generated product ID");
                return keys.getInt(1);
            }
        }
    }

    public boolean update(Product product) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "UPDATE products SET name = ?, price = ?, quantity = ? WHERE id = ?")) {
            bind(statement, product);
            statement.setInt(4, product.getId());
            // Một số cấu hình JDBC trả về 0 nếu giá trị không thay đổi.
            return statement.executeUpdate() > 0 || exists(connection, product.getId());
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement("DELETE FROM products WHERE id = ?")) {
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        }
    }

    private boolean exists(Connection connection, int id) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("SELECT id FROM products WHERE id = ?")) {
            statement.setInt(1, id);
            try (ResultSet rows = statement.executeQuery()) { return rows.next(); }
        }
    }

    private static void bind(PreparedStatement statement, Product product) throws SQLException {
        statement.setString(1, product.getName());
        statement.setBigDecimal(2, product.getPrice());
        statement.setInt(3, product.getQuantity());
    }

    private static Product read(ResultSet rows) throws SQLException {
        return new Product(rows.getInt("id"), rows.getString("name"),
                rows.getBigDecimal("price"), rows.getInt("quantity"));
    }
}

```

### src/main/java/com/codegym/products/model/Product.java

```java
package com.codegym.products.model;

import java.math.BigDecimal;

public class Product {
    private final int id;
    private final String name;
    private final BigDecimal price;
    private final int quantity;

    public Product(int id, String name, BigDecimal price, int quantity) {
        this.id = id;
        this.name = name;
        this.price = price;
        this.quantity = quantity;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public int getQuantity() { return quantity; }
}

```

### src/main/java/com/codegym/products/web/Html.java

```java
package com.codegym.products.web;

public final class Html {
    private Html() { }

    public static String escape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
}

```

### src/main/java/com/codegym/products/web/ProductForm.java

```java
package com.codegym.products.web;

import com.codegym.products.model.Product;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

/** Giữ dữ liệu gốc để hiển thị lại biểu mẫu khi nhập sai. */
public class ProductForm {
    private final int id;
    private final String name;
    private final String price;
    private final String quantity;

    public ProductForm(int id, String name, String price, String quantity) {
        this.id = id;
        this.name = name == null ? "" : name;
        this.price = price == null ? "" : price;
        this.quantity = quantity == null ? "" : quantity;
    }

    public static ProductForm empty() { return new ProductForm(0, "", "", ""); }
    public static ProductForm from(Product product) {
        return new ProductForm(product.getId(), product.getName(),
                product.getPrice().toPlainString(), Integer.toString(product.getQuantity()));
    }

    public Map<String, String> validate() {
        Map<String, String> errors = new LinkedHashMap<>();
        String cleanName = name.strip();
        if (cleanName.isEmpty() || cleanName.codePointCount(0, cleanName.length()) > 255)
            errors.put("name", "Tên sản phẩm phải có từ 1 đến 255 ký tự.");
        String cleanPrice = price.strip();
        if (cleanPrice.length() > 32 || !cleanPrice.matches("[0-9]+(?:\\.[0-9]{1,2})?")) {
            errors.put("price", "Giá phải là số không âm, tối đa 2 chữ số thập phân (dùng dấu chấm).");
        } else if (new BigDecimal(cleanPrice).compareTo(new BigDecimal("9999999999999.99")) > 0) {
            errors.put("price", "Giá vượt quá giới hạn 9.999.999.999.999,99.");
        }
        try {
            String cleanQuantity = quantity.strip();
            if (!cleanQuantity.matches("[0-9]{1,10}") || Integer.parseInt(cleanQuantity) < 0)
                throw new NumberFormatException();
        } catch (NumberFormatException e) {
            errors.put("quantity", "Số lượng phải là số nguyên từ 0 đến 2147483647.");
        }
        return errors;
    }

    public Product toProduct() {
        if (!validate().isEmpty()) throw new IllegalArgumentException("Invalid product form");
        return new Product(id, name.strip(), new BigDecimal(price.strip()).setScale(2),
                Integer.parseInt(quantity.strip()));
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getPrice() { return price; }
    public String getQuantity() { return quantity; }
}

```

### src/main/java/com/codegym/products/web/ProductServlet.java

```java
package com.codegym.products.web;

import com.codegym.products.dao.Database;
import com.codegym.products.dao.ProductDAO;
import com.codegym.products.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

public class ProductServlet extends HttpServlet {
    private ProductDAO dao;

    @Override public void init() { dao = new ProductDAO(new Database()); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        try {
            switch (action(request, "list")) {
                case "list" -> {
                    request.setAttribute("products", dao.findAll());
                    HttpSession session = request.getSession();
                    request.setAttribute("message", session.getAttribute("message"));
                    session.removeAttribute("message");
                    render("list", request, response);
                }
                case "create" -> {
                    request.setAttribute("form", ProductForm.empty());
                    render("form", request, response);
                }
                case "edit", "confirm-delete" -> {
                    Optional<Product> product = dao.findById(id(request));
                    if (product.isEmpty()) {
                        error(404, "Không tìm thấy sản phẩm.", request, response);
                    } else if ("edit".equals(request.getParameter("action"))) {
                        request.setAttribute("form", ProductForm.from(product.get()));
                        render("form", request, response);
                    } else {
                        request.setAttribute("product", product.get());
                        render("delete", request, response);
                    }
                }
                default -> error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        } catch (SQLException e) {
            databaseError(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        String token = request.getParameter("csrf");
        if (token == null || !token.equals(request.getSession().getAttribute("csrf"))) {
            error(403, "Phiên biểu mẫu không hợp lệ. Hãy mở lại trang và thử lại.", request, response);
            return;
        }
        try {
            String action = action(request, "");
            if ("create".equals(action) || "update".equals(action)) {
                int productId = "update".equals(action) ? id(request) : 0;
                ProductForm form = new ProductForm(productId, request.getParameter("name"),
                        request.getParameter("price"), request.getParameter("quantity"));
                Map<String, String> errors = form.validate();
                if (!errors.isEmpty()) {
                    response.setStatus(400);
                    request.setAttribute("form", form);
                    request.setAttribute("errors", errors);
                    render("form", request, response);
                    return;
                }
                if (productId == 0) {
                    dao.insert(form.toProduct());
                    success("Đã thêm sản phẩm.", request, response);
                } else if (dao.update(form.toProduct())) {
                    success("Đã cập nhật sản phẩm.", request, response);
                } else {
                    error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
                }
            } else if ("delete".equals(action)) {
                if (!"yes".equals(request.getParameter("confirmed"))) {
                    error(400, "Bạn cần xác nhận trước khi xoá sản phẩm.", request, response);
                } else if (dao.delete(id(request))) {
                    success("Đã xoá sản phẩm.", request, response);
                } else {
                    error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
                }
            } else {
                error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        } catch (SQLException e) {
            databaseError(request, response, e);
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
        String value = request.getParameter("action");
        return value == null ? fallback : value;
    }

    private static int id(HttpServletRequest request) {
        int value = Integer.parseInt(request.getParameter("id"));
        if (value <= 0) throw new IllegalArgumentException("Invalid ID");
        return value;
    }

    private static void render(String view, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(request, response);
    }

    private static void success(String message, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.getSession().setAttribute("message", message);
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.setHeader("Location", request.getContextPath() + "/products");
    }

    private static void error(int status, String message, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("errorMessage", message);
        render("error", request, response);
    }

    private void databaseError(HttpServletRequest request, HttpServletResponse response, SQLException e)
            throws ServletException, IOException {
        getServletContext().log("Product database operation failed", e);
        error(500, "Không thể truy cập dữ liệu. Hãy kiểm tra MySQL và cấu hình kết nối của ứng dụng.",
                request, response);
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
.container { width: min(1080px, calc(100% - 32px)); margin: 0 auto; }
main { padding: 32px 0; }
.narrow { max-width: 620px; }
h1 { font-size: 28px; line-height: 1.3; margin: 0 0 12px; }
.narrow h1 { margin-top: 18px; }
p { margin: 0 0 16px; }
.muted, footer { color: #576678; }
.toolbar { display: flex; justify-content: space-between; align-items: center; gap: 20px; margin-bottom: 20px; }
.toolbar p { margin: 0; }
.button, button { display: inline-block; border: 1px solid transparent; border-radius: 6px; background: #1b57b0; color: white; font: inherit; font-weight: bold; padding: 10px 17px; text-decoration: none; cursor: pointer; }
.button:hover, button:hover { color: white; background: #123e80; }
.secondary { color: #172b46; background: #e9eef5; }
.secondary:hover { color: #172b46; background: #d8e1ed; }
.danger { background: #b22b36; }
.danger:hover { background: #8f2029; }
.danger-link { color: #a52431; }
.table-wrapper { overflow-x: auto; border: 1px solid #d4dde8; border-radius: 8px; background: white; }
table { border-collapse: collapse; width: 100%; min-width: 580px; }
th, td { text-align: left; padding: 14px 18px; border-bottom: 1px solid #e3e9f0; }
th { background: #eaf0f7; white-space: nowrap; }
tbody tr:last-child td { border-bottom: 0; }
td { overflow-wrap: anywhere; }
.number { text-align: right; font-variant-numeric: tabular-nums; white-space: nowrap; }
.actions { white-space: nowrap; }
.actions a + a { margin-left: 16px; }
.empty { text-align: center; color: #576678; padding: 32px; }
.card { padding: 24px; background: white; border: 1px solid #d4dde8; border-radius: 8px; }
label { display: block; font-weight: bold; margin: 12px 0 6px; }
input:not([type="hidden"]) { width: 100%; border: 1px solid #8193aa; border-radius: 5px; padding: 10px 12px; font: inherit; }
input[aria-invalid="true"] { border-color: #b22b36; }
:focus-visible { outline: 3px solid #eeaa20; outline-offset: 3px; }
.field-error { font-size: 14px; color: #a52431; margin: 4px 0 12px; }
.field-error:empty { display: none; }
.form-actions { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 24px; }
.notice, .error { padding: 12px 16px; border-radius: 5px; }
.notice { color: #185b3e; background: #e3f4eb; border: 1px solid #acd6bc; }
.error { color: #8d202b; background: #fce8eb; border: 1px solid #efbec5; }
dl { display: grid; grid-template-columns: 130px 1fr; gap: 6px 16px; }
dt { font-weight: bold; }
dd { margin: 0; }
footer { padding-bottom: 24px; font-size: 14px; }
.visually-hidden { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0, 0, 0, 0); white-space: nowrap; border: 0; }
@media (max-width: 600px) {
    .toolbar { align-items: flex-start; flex-direction: column; }
    h1 { font-size: 24px; }
    .card { padding: 18px; }
    th, td { padding: 12px; }
}

```

### src/main/webapp/WEB-INF/views/delete.jsp

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codegym.products.model.Product,com.codegym.products.web.Html" %>
<%
    Product product = (Product) request.getAttribute("product");
    String base = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Xác nhận xoá sản phẩm</title>
    <link rel="stylesheet" href="<%= base %>/assets/styles.css">
</head>
<body>
<header><div class="container"><a class="brand" href="<%= base %>/products">Quản lý sản phẩm</a></div></header>
<main class="container narrow">
    <h1>Xác nhận xoá sản phẩm</h1>
    <div class="card">
        <p>Bạn có muốn xoá sản phẩm <strong><%= Html.escape(product.getName()) %></strong> không?</p>
        <dl><dt>ID</dt><dd><%= product.getId() %></dd><dt>Giá (VNĐ)</dt><dd><%= product.getPrice().toPlainString() %></dd><dt>Số lượng</dt><dd><%= product.getQuantity() %></dd></dl>
        <p class="muted">Sau khi xác nhận, sản phẩm sẽ được xoá khỏi cơ sở dữ liệu.</p>
        <form action="<%= base %>/products" method="post">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= product.getId() %>">
            <input type="hidden" name="csrf" value="<%= Html.escape((String) session.getAttribute("csrf")) %>">
            <div class="form-actions"><button class="danger" type="submit" name="confirmed" value="yes">Xác nhận xoá</button><a class="button secondary" href="<%= base %>/products">Huỷ</a></div>
        </form>
    </div>
</main>
</body>
</html>

```

### src/main/webapp/WEB-INF/views/error.jsp

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.codegym.products.web.Html" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Không thể thực hiện yêu cầu</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/styles.css">
</head>
<body>
<main class="container narrow">
    <h1>Không thể thực hiện yêu cầu</h1>
    <p class="error" role="alert"><%= Html.escape((String) request.getAttribute("errorMessage")) %></p>
    <a class="button" href="<%= request.getContextPath() %>/products">Về danh sách sản phẩm</a>
</main>
</body>
</html>

```

### src/main/webapp/WEB-INF/views/form.jsp

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Map,com.codegym.products.web.ProductForm,com.codegym.products.web.Html" %>
<%
    ProductForm form = (ProductForm) request.getAttribute("form");
    Map<String, String> errors = (Map<String, String>) request.getAttribute("errors");
    if (errors == null) errors = Map.of();
    boolean editing = form.getId() > 0;
    String title = editing ? "Sửa sản phẩm" : "Thêm sản phẩm";
    String base = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= title %></title>
    <link rel="stylesheet" href="<%= base %>/assets/styles.css">
</head>
<body>
<header><div class="container"><a class="brand" href="<%= base %>/products">Quản lý sản phẩm</a></div></header>
<main class="container narrow">
    <a href="<%= base %>/products">← Danh sách sản phẩm</a>
    <h1><%= title %></h1>
    <% if (!errors.isEmpty()) { %><p class="error" role="alert">Vui lòng kiểm tra các trường được đánh dấu bên dưới.</p><% } %>
    <form class="card" action="<%= base %>/products" method="post">
        <input type="hidden" name="action" value="<%= editing ? "update" : "create" %>">
        <input type="hidden" name="csrf" value="<%= Html.escape((String) session.getAttribute("csrf")) %>">
        <% if (editing) { %><input type="hidden" name="id" value="<%= form.getId() %>"><p class="muted">Mã sản phẩm: <%= form.getId() %></p><% } %>
        <label for="name">Tên sản phẩm</label>
        <input id="name" name="name" type="text" maxlength="255" required value="<%= Html.escape(form.getName()) %>" aria-describedby="name-error" <%= errors.containsKey("name") ? "aria-invalid=\"true\"" : "" %>>
        <p class="field-error" id="name-error"><%= Html.escape(errors.get("name")) %></p>

        <label for="price">Giá (VNĐ)</label>
        <input id="price" name="price" type="number" min="0" max="9999999999999.99" step="0.01" required value="<%= Html.escape(form.getPrice()) %>" aria-describedby="price-error" <%= errors.containsKey("price") ? "aria-invalid=\"true\"" : "" %>>
        <p class="field-error" id="price-error"><%= Html.escape(errors.get("price")) %></p>

        <label for="quantity">Số lượng</label>
        <input id="quantity" name="quantity" type="number" min="0" max="2147483647" step="1" required value="<%= Html.escape(form.getQuantity()) %>" aria-describedby="quantity-error" <%= errors.containsKey("quantity") ? "aria-invalid=\"true\"" : "" %>>
        <p class="field-error" id="quantity-error"><%= Html.escape(errors.get("quantity")) %></p>

        <div class="form-actions"><button type="submit"><%= editing ? "Lưu thay đổi" : "Thêm sản phẩm" %></button><a class="button secondary" href="<%= base %>/products">Huỷ</a></div>
    </form>
</main>
</body>
</html>

```

### src/main/webapp/WEB-INF/views/list.jsp

```jsp
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,com.codegym.products.model.Product,com.codegym.products.web.Html" %>
<%
    List<Product> products = (List<Product>) request.getAttribute("products");
    String base = request.getContextPath();
    String message = (String) request.getAttribute("message");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Danh sách sản phẩm</title>
    <link rel="stylesheet" href="<%= base %>/assets/styles.css">
</head>
<body>
<header><div class="container"><a class="brand" href="<%= base %>/products">Quản lý sản phẩm</a></div></header>
<main class="container">
    <div class="toolbar">
        <div><h1>Danh sách sản phẩm</h1><p class="muted">Tổng cộng <%= products.size() %> sản phẩm</p></div>
        <a class="button" href="<%= base %>/products?action=create">+ Thêm sản phẩm</a>
    </div>
    <% if (message != null) { %><p class="notice" role="status"><%= Html.escape(message) %></p><% } %>
    <div class="table-wrapper">
        <table>
            <caption class="visually-hidden">Sản phẩm đang có trong cơ sở dữ liệu</caption>
            <thead><tr><th scope="col">ID</th><th scope="col">Tên sản phẩm</th><th scope="col" class="number">Giá (VNĐ)</th><th scope="col" class="number">Số lượng</th><th scope="col">Thao tác</th></tr></thead>
            <tbody>
            <% if (products.isEmpty()) { %>
                <tr><td colspan="5" class="empty">Chưa có sản phẩm. Hãy thêm sản phẩm đầu tiên.</td></tr>
            <% } else { for (Product product : products) { %>
                <tr>
                    <td><%= product.getId() %></td>
                    <td><%= Html.escape(product.getName()) %></td>
                    <td class="number"><%= product.getPrice().toPlainString() %></td>
                    <td class="number"><%= product.getQuantity() %></td>
                    <td class="actions">
                        <a href="<%= base %>/products?action=edit&amp;id=<%= product.getId() %>">Sửa</a>
                        <a class="danger-link" href="<%= base %>/products?action=confirm-delete&amp;id=<%= product.getId() %>">Xoá</a>
                    </td>
                </tr>
            <% } } %>
            </tbody>
        </table>
    </div>
</main>
<footer class="container">Bài kiểm tra cuối module · DTC245200382</footer>
</body>
</html>

```

### src/main/webapp/WEB-INF/web.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>Quản lý sản phẩm - Final Exam</display-name>
    <servlet>
        <servlet-name>ProductServlet</servlet-name>
        <servlet-class>com.codegym.products.web.ProductServlet</servlet-class>
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

### src/test/java/com/codegym/products/web/ProductFormTest.java

```java
package com.codegym.products.web;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ProductFormTest {
    @Test void acceptsVietnameseAndPreservesDecimalMoney() {
        ProductForm form = new ProductForm(7, "  Bàn phím cơ  ", " 1250.10 ", "12");
        assertTrue(form.validate().isEmpty());
        assertEquals(7, form.toProduct().getId());
        assertEquals("Bàn phím cơ", form.toProduct().getName());
        assertEquals(new BigDecimal("1250.10"), form.toProduct().getPrice());
    }

    @Test void acceptsZeroAndMaximumStorageValues() {
        assertTrue(new ProductForm(0, "Hàng mẫu", "0", "0").validate().isEmpty());
        ProductForm max = new ProductForm(0, "A".repeat(255), "9999999999999.99", "2147483647");
        assertTrue(max.validate().isEmpty());
        assertEquals(new BigDecimal("9999999999999.99"), max.toProduct().getPrice());
    }

    @Test void rejectsBlankOrTooLongNames() {
        assertTrue(new ProductForm(0, " \t", "1", "1").validate().containsKey("name"));
        assertTrue(new ProductForm(0, "A".repeat(256), "1", "1").validate().containsKey("name"));
    }

    @Test void rejectsInvalidMoneyWithoutSilentlyRounding() {
        for (String value : new String[]{"", "-1", "1.001", "NaN", "1e3", "1,5", "10000000000000"})
            assertTrue(new ProductForm(0, "A", value, "1").validate().containsKey("price"), value);
    }

    @Test void rejectsInvalidQuantity() {
        for (String value : new String[]{"", "-1", "1.5", "abc", "2147483648", "999999999999"})
            assertTrue(new ProductForm(0, "A", "1", value).validate().containsKey("quantity"), value);
    }

    @Test void preservesSubmittedDataForErrorsAndRefusesConversion() {
        ProductForm form = new ProductForm(3, " Tên gốc ", "abc", "4");
        assertEquals(" Tên gốc ", form.getName());
        assertEquals("abc", form.getPrice());
        assertThrows(IllegalArgumentException.class, form::toProduct);
    }

    @Test void escapesUserInputInHtmlAndAttributes() {
        assertEquals("&lt;script&gt;&amp;&quot;&#39;", Html.escape("<script>&\"'"));
        assertEquals("", Html.escape(null));
    }
}

```
