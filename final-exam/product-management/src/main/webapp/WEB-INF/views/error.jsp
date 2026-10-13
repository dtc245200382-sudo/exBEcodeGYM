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
