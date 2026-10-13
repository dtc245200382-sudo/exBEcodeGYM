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
