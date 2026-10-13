# [Thực hành] Ứng dụng quản lý khách hàng — Khung dự án MVC

Mã số sinh viên: **DTC245200382**

Ngày tạo và kiểm tra biên dịch: **13/10/2026**.

## 1. Phạm vi phần AI hỗ trợ theo đề bài

Trong **Bước 1 — Yêu cầu về việc sinh mã (BẮT BUỘC)**, đề yêu cầu AI chỉ viết cấu hình hoàn chỉnh, còn các class Java và JSP chỉ được tạo khung. Đề còn nêu:

> TUYỆT ĐỐI không được tự động sinh bất kỳ dòng code logic xử lý nghiệp vụ, xử lý luồng GET/POST hay mã nguồn HTML/JSTL giao diện hoàn thiện nào.

Vì vậy, bản này hoàn thành **phần khởi tạo dự án**, có thể biên dịch và đóng gói WAR. **Đây chưa phải ứng dụng CRUD hoàn chỉnh và chưa đáp ứng phần thực hành chức năng ở Bước 3.** Học viên cần tự hoàn thiện Model, Service, Controller và các trang JSP trước khi nộp bản ứng dụng hoàn chỉnh.

Tài liệu này gom cấu trúc, hướng dẫn, kết quả build và toàn bộ mã nguồn khung vào một file. Dự án Maven tương ứng nằm trong thư mục `customer-management` bên cạnh tài liệu này.

## 2. Cấu trúc đã tạo

Đường dẫn tuyệt đối trên máy: `E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-khach-hang\customer-management`.

```text
customer-management/
├── .gitignore
├── pom.xml
└── src/main/
    ├── java/com/codegym/
    │   ├── model/Customer.java
    │   ├── service/CustomerService.java
    │   ├── service/CustomerServiceImpl.java
    │   └── controller/CustomerServlet.java
    └── webapp/
        ├── WEB-INF/web.xml
        ├── customer/
        │   ├── list.jsp
        │   ├── create.jsp
        │   ├── edit.jsp
        │   ├── delete.jsp
        │   └── view.jsp
        └── error-404.jsp
```

Maven dùng `groupId=com.codegym`, `artifactId=customer-management`, Java 17, kiểu đóng gói WAR và tên WAR `customer-management.war`.

Thư viện theo mẫu cấu hình của đề:

| Vai trò | Dependency |
| --- | --- |
| Servlet API | `jakarta.servlet:jakarta.servlet-api:6.0.0`, scope provided |
| JSP API | `jakarta.servlet.jsp:jakarta.servlet.jsp-api:3.1.1`, scope provided |
| JSTL API | `jakarta.servlet.jsp.jstl:jakarta.servlet.jsp.jstl-api:3.0.0` |
| JSTL implementation | `org.glassfish.web:jakarta.servlet.jsp.jstl:3.0.1` |

Implementation dùng đúng artifact trong `pom.xml` mẫu của đề; không sử dụng một artifact tên `jakarta.servlet.jsp.jstl-impl` chưa được xác định. Đã sửa các thẻ Maven bị lỗi định dạng trong văn bản đề thành XML hợp lệ.

`web.xml` ánh xạ `com.codegym.controller.CustomerServlet` tới `/customers`, đặt welcome file và trang lỗi 404. Không khai báo thêm `@WebServlet` để tránh ánh xạ trùng.

## 3. Các phần học viên cần hoàn thiện

| Tệp | Công việc tiếp theo |
| --- | --- |
| `Customer.java` | Bỏ `abstract`, viết constructor và thân getter/setter cho id, name, email, address |
| `CustomerServiceImpl.java` | Bỏ `abstract`, khởi tạo Map tĩnh, thêm dữ liệu mẫu và triển khai 5 phương thức trong interface |
| `CustomerServlet.java` | Khởi tạo Service, xử lý GET/POST, đọc action/ID, chuyển dữ liệu cho JSP và xử lý khách hàng không tồn tại |
| `list.jsp` | Danh sách khách hàng, liên kết thêm mới, sửa, xoá và xem chi tiết |
| `create.jsp` | Form tạo khách hàng với name, email, address |
| `edit.jsp` | Form chứa thông tin hiện có và ID ẩn |
| `delete.jsp` | Trang xác nhận xoá và nút Huỷ |
| `view.jsp` | Hiển thị id, name, email, address của khách hàng |
| `error-404.jsp` | Thông báo không tìm thấy khách hàng và liên kết về danh sách |

Hai class Model và ServiceImpl dùng phương thức `abstract` để chỉ có chữ ký mà dự án vẫn biên dịch. Các file JSP chỉ chứa comment JSP, chưa chứa HTML hoặc JSTL giao diện. Servlet là khai báo lớp cơ bản kế thừa `HttpServlet`, chưa triển khai GET/POST.

Dữ liệu theo đề sẽ nằm trong Map tĩnh, không yêu cầu MySQL; dữ liệu sẽ mất khi ứng dụng được khởi động lại. Khi tự viết phần lưu khách hàng, cần tránh ID trùng làm ghi đè bản ghi cũ.

## 4. Biên dịch

Yêu cầu JDK 17 và Maven. Mở terminal trong thư mục `customer-management` rồi chạy:

```powershell
mvn clean package
```

Kết quả tạo `target/customer-management.war`. Thư mục `target` được bỏ qua khi đưa mã nguồn lên GitHub; có thể tạo lại WAR bằng lệnh trên.

Đã kiểm tra bằng JDK **17.0.20.1** và Maven **3.9.9**: **BUILD SUCCESS**; 4 file Java được biên dịch. Đã kiểm tra WAR chứa 4 class, 6 JSP, `web.xml` và hai thư viện JSTL.

**Chưa kiểm thử thêm/sửa/xoá/xem chi tiết** vì phần nghiệp vụ và giao diện chưa được viết. Thông báo `No tests to run` trong log là đúng với khung dự án; không được coi là kiểm thử chức năng thành công.

## 5. Triển khai sau khi tự hoàn thiện

Sau khi bổ sung code và build lại, triển khai `target/customer-management.war` vào Tomcat 10.1 rồi mở:

`http://localhost:8080/customer-management/customers`

Đề có prompt triển khai yêu cầu hiển thị lệnh để phê duyệt trước khi chạy. Prompt triển khai đó chưa được thực hiện trong lượt tạo khung này. Hiện Servlet chưa có xử lý GET/POST nên chưa thể hiển thị danh sách khi truy cập URL trên.

## 6. Tham khảo

- Tệp đề bài do người dùng cung cấp: `[Thực hành] Ứng dụng quản lý khách hàng`.
- [Tài liệu Apache Tomcat 10.1: Servlet 6.0 và JSP 3.1](https://tomcat.apache.org/tomcat-10.1-doc/index.html).
- [Jakarta Standard Tag Library 3.0](https://jakarta.ee/specifications/tags/3.0/) — khi tự hoàn thiện JSP, dùng namespace Jakarta như `jakarta.tags.core`.

Phần cấu hình và khung khai báo được tạo với hỗ trợ ChatGPT/Codex, tuân theo giới hạn sinh mã trong Bước 1 của đề. Mã nguồn nghiệp vụ mẫu ở Bước 3 không được tự động điền vào dự án.

## 7. Log biên dịch thực tế

```text
[INFO] Downloaded from central: https://repo.maven.apache.org/maven2/org/glassfish/web/jakarta.servlet.jsp.jstl/3.0.1/jakarta.servlet.jsp.jstl-3.0.1.jar (3.7 MB at 3.9 MB/s)
[INFO]
[INFO] --- clean:3.2.0:clean (default-clean) @ customer-management ---
[INFO]
[INFO] --- resources:3.3.1:resources (default-resources) @ customer-management ---
[INFO] skip non existing resourceDirectory E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-khach-hang\customer-management\src\main\resources
[INFO]
[INFO] --- compiler:3.13.0:compile (default-compile) @ customer-management ---
[INFO] Recompiling the module because of changed dependency.
[INFO] Compiling 4 source files with javac [debug release 17] to target\classes
[INFO]
[INFO] --- resources:3.3.1:testResources (default-testResources) @ customer-management ---
[INFO] skip non existing resourceDirectory E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-khach-hang\customer-management\src\test\resources
[INFO]
[INFO] --- compiler:3.13.0:testCompile (default-testCompile) @ customer-management ---
[INFO] No sources to compile
[INFO]
[INFO] --- surefire:3.2.5:test (default-test) @ customer-management ---
[INFO] No tests to run.
[INFO]
[INFO] --- war:3.4.0:war (default-war) @ customer-management ---
[INFO] Packaging webapp
[INFO] Assembling webapp [customer-management] in [E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-khach-hang\customer-management\target\customer-management]
[INFO] Processing war project
[INFO] Copying webapp resources [E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-khach-hang\customer-management\src\main\webapp]
[INFO] Building war: E:\BaitapinternCodeGYM\exBEcodeGYM\quan-ly-khach-hang\customer-management\target\customer-management.war
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  4.202 s
[INFO] Finished at: 2026-10-13T18:47:47+07:00
[INFO] ------------------------------------------------------------------------
WAR CONTENT CHECK: PASS (13 required entries)
```

## 8. Toàn bộ mã nguồn khung

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
    <artifactId>customer-management</artifactId>
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
            <groupId>jakarta.servlet.jsp</groupId>
            <artifactId>jakarta.servlet.jsp-api</artifactId>
            <version>3.1.1</version>
            <scope>provided</scope>
        </dependency>
        <dependency>
            <groupId>jakarta.servlet.jsp.jstl</groupId>
            <artifactId>jakarta.servlet.jsp.jstl-api</artifactId>
            <version>3.0.0</version>
        </dependency>
        <!-- Đây là artifact implementation JSTL Jakarta dùng trong mẫu của đề. -->
        <dependency>
            <groupId>org.glassfish.web</groupId>
            <artifactId>jakarta.servlet.jsp.jstl</artifactId>
            <version>3.0.1</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>customer-management</finalName>
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
        </plugins>
    </build>
</project>
```

### src/main/java/com/codegym/controller/CustomerServlet.java

```java
package com.codegym.controller;

import jakarta.servlet.http.HttpServlet;

/**
 * Khung Controller của ứng dụng MVC; ánh xạ /customers nằm trong web.xml.
 * Học viên tự khai báo Service và triển khai doGet/doPost.
 * GET: danh sách, form thêm/sửa/xoá và chi tiết khách hàng.
 * POST: thêm mới, cập nhật và xoá khách hàng.
 * Chưa có phương thức xử lý hoặc điều hướng JSP trong khung này.
 */
public class CustomerServlet extends HttpServlet {
}
```

### src/main/java/com/codegym/model/Customer.java

```java
package com.codegym.model;

/**
 * Khung Model khách hàng gồm id, name, email và address.
 * Học viên tự viết constructor, getter và setter theo mã tham khảo trong đề.
 * Các phương thức abstract chỉ khai báo chữ ký, không chứa logic.
 * Khi hoàn thiện, bỏ abstract và bổ sung thân các phương thức.
 */
public abstract class Customer {
    private int id;
    private String name;
    private String email;
    private String address;

    public abstract int getId();
    public abstract void setId(int id);
    public abstract String getName();
    public abstract void setName(String name);
    public abstract String getEmail();
    public abstract void setEmail(String email);
    public abstract String getAddress();
    public abstract void setAddress(String address);
}
```

### src/main/java/com/codegym/service/CustomerService.java

```java
package com.codegym.service;

import com.codegym.model.Customer;
import java.util.List;

/** Hợp đồng của tầng Service; không chứa phần triển khai nghiệp vụ. */
public interface CustomerService {
    /** Trả về danh sách khách hàng. */
    List<Customer> findAll();

    /** Lưu một khách hàng mới. */
    void save(Customer customer);

    /** Tìm khách hàng theo ID; quy ước trả về null khi không tồn tại. */
    Customer findById(int id);

    /** Cập nhật khách hàng đã có theo ID. */
    void update(int id, Customer customer);

    /** Xoá khách hàng theo ID. */
    void remove(int id);
}
```

### src/main/java/com/codegym/service/CustomerServiceImpl.java

```java
package com.codegym.service;

import com.codegym.model.Customer;
import java.util.List;
import java.util.Map;

/**
 * Khung triển khai Service với Map tĩnh giả lập cơ sở dữ liệu.
 * Học viên tự khởi tạo Map, thêm dữ liệu mẫu và triển khai các phương thức.
 * Dữ liệu Map chỉ tồn tại trong bộ nhớ khi ứng dụng đang chạy.
 * Lớp abstract giúp khung chữ ký biên dịch được mà chưa có logic nghiệp vụ.
 */
public abstract class CustomerServiceImpl implements CustomerService {
    private static Map<Integer, Customer> customers;

    @Override public abstract List<Customer> findAll();
    @Override public abstract void save(Customer customer);
    @Override public abstract Customer findById(int id);
    @Override public abstract void update(int id, Customer customer);
    @Override public abstract void remove(int id);
}
```

### src/main/webapp/customer/create.jsp

```jsp
<%-- Khung View thêm mới: học viên tự viết form name, email, address và gửi POST tới /customers với action=create. --%>
```

### src/main/webapp/customer/delete.jsp

```jsp
<%-- Khung View xác nhận xoá: học viên tự hiển thị khách hàng, nút xác nhận POST action=delete và liên kết Huỷ. --%>
```

### src/main/webapp/customer/edit.jsp

```jsp
<%-- Khung View chỉnh sửa: học viên tự viết form có ID ẩn, thông tin hiện tại và POST với action=edit. --%>
```

### src/main/webapp/customer/list.jsp

```jsp
<%-- Khung View danh sách: học viên tự viết HTML và JSTL hiển thị khách hàng cùng các liên kết Thêm, Sửa, Xoá, Xem. --%>
```

### src/main/webapp/customer/view.jsp

```jsp
<%-- Khung View chi tiết: học viên tự hiển thị id, name, email, address và liên kết quay về danh sách. --%>
```

### src/main/webapp/error-404.jsp

```jsp
<%-- Khung View lỗi 404: học viên tự viết thông báo không tìm thấy khách hàng và liên kết quay về danh sách. --%>
```

### src/main/webapp/WEB-INF/web.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>Customer Management MVC</display-name>

    <servlet>
        <servlet-name>CustomerServlet</servlet-name>
        <servlet-class>com.codegym.controller.CustomerServlet</servlet-class>
        <load-on-startup>1</load-on-startup>
    </servlet>
    <servlet-mapping>
        <servlet-name>CustomerServlet</servlet-name>
        <url-pattern>/customers</url-pattern>
    </servlet-mapping>

    <welcome-file-list>
        <welcome-file>customers</welcome-file>
    </welcome-file-list>
    <error-page>
        <error-code>404</error-code>
        <location>/error-404.jsp</location>
    </error-page>
    <session-config>
        <session-timeout>30</session-timeout>
    </session-config>
</web-app>
```
