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
