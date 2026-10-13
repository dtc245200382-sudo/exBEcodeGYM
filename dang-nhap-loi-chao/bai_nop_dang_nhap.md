# Thực hành: Đăng nhập và hiển thị lời chào

Một file nộp chung chứa mã nguồn và kết quả kiểm thử. Dự án Maven để chạy: [jsp-servlet-login](./jsp-servlet-login).

## Chức năng theo đề

- index.jsp có form username, password và nút Login.
- Form dùng POST gửi tới /login; LoginServlet nhận dữ liệu bằng getParameter.
- Đúng admin/admin: Welcome admin to website.
- Sai hoặc thiếu dữ liệu: Login Error.
- GET /login chuyển về trang chứa form.
- Tài khoản cố định phục vụ bài thực hành; không lưu mật khẩu người dùng hoặc tạo phiên đăng nhập.

## Cách build và chạy

1. Dùng JDK 17, Maven và Tomcat 10.1. Cấu hình JAVA_HOME trỏ tới JDK.
2. Trong thư mục jsp-servlet-login, chạy:

```shell
mvn clean package
```

3. Copy target/jsp-servlet-login.war vào webapps của Tomcat.
4. Khởi động bằng bin/startup.bat (Windows) hoặc bin/startup.sh (Linux/macOS).
5. Mở http://localhost:8080/jsp-servlet-login/ và nhập tài khoản thử.

JSP/Servlet phải được chạy qua Tomcat; GitHub chỉ hiển thị mã nguồn.

## Toàn bộ mã nguồn

### pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.codegym</groupId>
    <artifactId>jsp-servlet-login</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>war</packaging>
    <name>CodeGym - Dang nhap va loi chao</name>
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
        <finalName>jsp-servlet-login</finalName>
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

### src/main/webapp/index.jsp

```jsp
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% response.setHeader("Cache-Control", "no-store"); %>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Login</title>
    <style>
        body { margin: 0; padding: 24px; background: #f8fafc; color: #25334b; font-family: Arial, sans-serif; }
        main { max-width: 360px; margin: 70px auto; padding: 30px; border: 1px solid #e1e6ee; border-radius: 10px; background: white; }
        h1 { margin-top: 0; color: #1b2a7a; font-size: 26px; text-align: center; }
        label { display: block; margin-top: 18px; font-size: 14px; }
        input { box-sizing: border-box; width: 100%; margin-top: 6px; padding: 11px; border: 1px solid #cbd5e1; border-radius: 5px; font: inherit; }
        button { width: 100%; margin-top: 24px; padding: 12px; border: 0; border-radius: 5px; background: #1b2a7a; color: white; font: inherit; cursor: pointer; }
        input:focus-visible, button:focus-visible { outline: 2px solid #537be5; outline-offset: 2px; }
        .note { margin-bottom: 0; color: #68748a; font-size: 13px; line-height: 1.6; text-align: center; }
    </style>
</head>
<body>
    <main>
        <h1>System Login</h1>
        <form action="<%= request.getContextPath() %>/login" method="POST">
            <label for="username">Tên đăng nhập</label>
            <input id="username" type="text" name="username" placeholder="Enter username"
                   autocomplete="username" required autofocus>
            <label for="password">Mật khẩu</label>
            <input id="password" type="password" name="password" placeholder="Enter password"
                   autocomplete="current-password" required>
            <button type="submit">Login</button>
        </form>
        <p class="note">Tài khoản thực hành: admin / admin</p>
    </main>
</body>
</html>

```

### src/main/java/com/codegym/LoginServlet.java

```java
package com.codegym;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendRedirect(request.getContextPath() + "/");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        // Tài khoản cố định chỉ phục vụ yêu cầu bài tập.
        boolean successful = "admin".equals(username) && "admin".equals(password);
        String message = successful ? "Welcome admin to website" : "Login Error";
        String color = successful ? "#24754b" : "#b42332";

        try (PrintWriter out = response.getWriter()) {
            out.printf("""
                    <!doctype html>
                    <html lang="vi">
                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Login Result</title>
                    </head>
                    <body style="font-family:Arial,sans-serif;text-align:center;padding:60px 20px;background:#f8fafc;">
                        <h1 style="color:%s;">%s</h1>
                        <p><a href="./">Go back</a></p>
                    </body>
                    </html>
                    """, color, message);
        }
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
    <display-name>CodeGym Login</display-name>
    <servlet>
        <servlet-name>LoginServlet</servlet-name>
        <servlet-class>com.codegym.LoginServlet</servlet-class>
    </servlet>
    <servlet-mapping>
        <servlet-name>LoginServlet</servlet-name>
        <url-pattern>/login</url-pattern>
    </servlet-mapping>
    <welcome-file-list>
        <welcome-file>index.jsp</welcome-file>
    </welcome-file-list>
</web-app>

```

## Kiểm thử thực tế

Đã chạy trên Tomcat thử riêng tại localhost:18780, kiểm tra qua HTTP và dừng server sau khi hoàn thành. Chưa chụp ảnh trình duyệt.

```text
JDK 17; Maven 3.9.9; Tomcat 10.1.61
mvn clean package: BUILD SUCCESS
GET /jsp-servlet-login/: HTTP 200, JSP form rendered with POST /login
Correct admin/admin: HTTP 200, Welcome admin to website — PASS
Incorrect password: HTTP 200, Login Error — PASS
Incorrect username: HTTP 200, Login Error — PASS
Missing fields: HTTP 200, Login Error — PASS
GET /login: redirects to login form — PASS

```