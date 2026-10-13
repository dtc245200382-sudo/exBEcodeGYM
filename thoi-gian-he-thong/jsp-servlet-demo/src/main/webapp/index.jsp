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
