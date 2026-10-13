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
