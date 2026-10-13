# Thực hành: Trang web hiển thị thời gian hệ thống

Bài nộp chung gồm mã nguồn Maven JSP/Servlet và kết quả chạy thực tế. Dự án chạy nằm trong [jsp-servlet-demo](./jsp-servlet-demo).

## Chức năng

- Trang chủ hiển thị thời gian hiện tại và múi giờ của máy chủ Java.
- Thời gian được tạo lại khi tải trang, không lấy từ đồng hồ JavaScript của trình duyệt.
- HelloServlet tại /hello lấy thời gian rồi forward tới JSP, sử dụng cùng một giao diện.
- Java 17; Jakarta Servlet 6.0; JSP 3.1; đóng gói WAR cho Tomcat 10.1.

## Build và chạy

1. Cài JDK 17 và Maven, cấu hình JAVA_HOME trỏ tới JDK.
2. Mở terminal trong thư mục jsp-servlet-demo và chạy:

```shell
mvn clean package
```

3. Copy target/jsp-servlet-demo.war vào thư mục webapps của Tomcat 10.1.
4. Chạy bin/startup.bat trên Windows hoặc bin/startup.sh trên Linux/macOS.
5. Mở http://localhost:8080/jsp-servlet-demo/ hoặc http://localhost:8080/jsp-servlet-demo/hello.

JSP cần máy chủ Java; mở trực tiếp index.jsp bằng trình duyệt hoặc GitHub không thực thi mã Java. Múi giờ theo cấu hình JVM của máy chủ; có thể cấu hình -Duser.timezone=Asia/Ho_Chi_Minh.

## Mã nguồn

### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>jsp-servlet-demo</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>CodeGym - Thoi gian he thong</name>

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
    </dependencies>

    <build>
        <finalName>jsp-servlet-demo</finalName>
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

### src/main/java/com/codegym/HelloServlet.java

```java
package com.codegym;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.ZonedDateTime;

public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setAttribute("serverTime", ZonedDateTime.now());
        request.setAttribute("fromServlet", Boolean.TRUE);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}

```

### src/main/webapp/WEB-INF/web.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    <display-name>CodeGym System Time</display-name>
    <servlet>
        <servlet-name>HelloServlet</servlet-name>
        <servlet-class>com.codegym.HelloServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>HelloServlet</servlet-name>
        <url-pattern>/hello</url-pattern>
    </servlet-mapping>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>

```

### src/main/webapp/index.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.ZonedDateTime,java.time.format.DateTimeFormatter" %>
<%
    response.setHeader("Cache-Control", "no-store");
    ZonedDateTime serverTime = (ZonedDateTime) request.getAttribute("serverTime");
    if (serverTime == null) {
        serverTime = ZonedDateTime.now();
    }
    String displayedTime = serverTime.format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
    String isoTime = serverTime.format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
    boolean fromServlet = Boolean.TRUE.equals(request.getAttribute("fromServlet"));
%>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thời gian hệ thống</title>
    <style>
        body { margin: 0; padding: 24px; background: #f5f7fb; color: #25334b; font-family: Arial, sans-serif; }
        main { max-width: 580px; margin: 60px auto; padding: 32px; border: 1px solid #e1e6ee; border-radius: 12px; background: white; text-align: center; }
        h1 { font-size: 28px; }
        time { display: block; margin: 24px 0 12px; color: #1b2a7a; font-size: clamp(24px, 5vw, 36px); font-weight: bold; }
        p { line-height: 1.6; }
        a { display: inline-block; margin: 6px; padding: 10px 16px; border-radius: 5px; background: #1b2a7a; color: white; text-decoration: none; }
        .muted { color: #68748a; font-size: 14px; }
    </style>
</head>
<body>
    <main>
        <h1>Thời gian hệ thống hiện tại</h1>
        <time id="server-time" datetime="<%= isoTime %>"><%= displayedTime %></time>
        <p class="muted">Múi giờ máy chủ: <strong><%= serverTime.getZone().getId() %></strong></p>
        <p>Thời gian được lấy từ máy chủ Java khi tải trang. Tải lại để xem thời gian mới.</p>
        <% if (fromServlet) { %>
            <p id="servlet-message">HelloServlet đã xử lý yêu cầu và chuyển dữ liệu tới JSP.</p>
        <% } %>
        <a href="<%= request.getContextPath() %>/">Tải lại trang chủ</a>
        <a href="<%= request.getContextPath() %>/hello">Đi tới HelloServlet</a>
    </main>
</body>
</html>

```

## Kết quả kiểm thử thực tế

Chạy trên server Tomcat thử riêng tại 127.0.0.1:18780, sau đó đã dừng server. Kiểm tra qua HTTP, chưa chụp ảnh trình duyệt.

```text
JDK 17; Apache Maven 3.9.9; Tomcat 10.1.61
mvn clean package: BUILD SUCCESS
GET /jsp-servlet-demo/: HTTP 200
GET /jsp-servlet-demo/hello: HTTP 200
JSP compiled; servlet forward verified; Cache-Control: no-store
Server time first request: 2026-10-13T16:04:09.4173967+07:00
Server time after reload: 2026-10-13T16:04:11.5152464+07:00
Fresh timestamp check: PASS
Timestamp advanced after reload: PASS

```

## Tham khảo

[Apache Tomcat 10.1 — Jakarta Servlet 6.0 và JSP 3.1](https://tomcat.apache.org/tomcat-10.1-doc/index.html).