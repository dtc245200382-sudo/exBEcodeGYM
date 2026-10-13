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
