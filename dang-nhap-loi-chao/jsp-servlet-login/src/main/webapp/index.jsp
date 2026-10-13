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
