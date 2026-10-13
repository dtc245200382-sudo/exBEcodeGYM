<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<div class="narrow">
    <h1>Xác nhận xoá sản phẩm</h1>
    <div class="card">
        <p>Bạn có muốn xoá sản phẩm <strong><c:out value="${product.name}"/></strong> không?</p>
        <dl><dt>ID</dt><dd>${product.id}</dd><dt>Giá (VNĐ)</dt><dd><c:out value="${product.price}"/></dd><dt>Nhà sản xuất</dt><dd><c:out value="${product.manufacturer}"/></dd></dl>
        <form action="<c:out value='${productsUrl}'/>" method="post">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="${product.id}">
            <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
            <div class="form-actions"><button class="danger" type="submit" name="confirmed" value="yes">Xác nhận xoá</button><a class="button secondary" href="<c:out value='${productsUrl}'/>">Huỷ</a></div>
        </form>
    </div>
</div>
<%@ include file="fragments/footer.jspf" %>
