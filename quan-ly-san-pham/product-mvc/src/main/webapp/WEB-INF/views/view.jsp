<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<c:url value="/products" var="editUrl"><c:param name="action" value="edit"/><c:param name="id" value="${product.id}"/></c:url>
<c:url value="/products" var="deleteUrl"><c:param name="action" value="delete"/><c:param name="id" value="${product.id}"/></c:url>
<div class="narrow">
    <a href="<c:out value='${productsUrl}'/>">← Danh sách sản phẩm</a>
    <h1>Chi tiết sản phẩm</h1>
    <div class="card">
        <dl>
            <dt>ID</dt><dd>${product.id}</dd>
            <dt>Tên sản phẩm</dt><dd><c:out value="${product.name}"/></dd>
            <dt>Giá (VNĐ)</dt><dd><c:out value="${product.price}"/></dd>
            <dt>Nhà sản xuất</dt><dd><c:out value="${product.manufacturer}"/></dd>
            <dt>Mô tả</dt><dd class="multiline"><c:out value="${product.description}"/></dd>
        </dl>
        <div class="form-actions"><a class="button" href="<c:out value='${editUrl}'/>">Sửa sản phẩm</a><a class="button danger" href="<c:out value='${deleteUrl}'/>">Xoá sản phẩm</a></div>
    </div>
</div>
<%@ include file="fragments/footer.jspf" %>
