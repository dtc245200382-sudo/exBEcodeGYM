<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<div class="narrow">
    <a href="<c:out value='${productsUrl}'/>">← Danh sách sản phẩm</a>
    <h1><c:out value="${pageTitle}"/></h1>
    <c:if test="${not empty errorMessage}"><p class="error" role="alert"><c:out value="${errorMessage}"/></p></c:if>
    <form class="card" action="<c:out value='${productsUrl}'/>" method="post">
        <input type="hidden" name="action" value="${form.id == 0 ? 'create' : 'edit'}">
        <input type="hidden" name="id" value="${form.id}">
        <input type="hidden" name="csrf" value="<c:out value='${sessionScope.csrf}'/>">
        <c:if test="${form.id > 0}"><p class="muted">Mã sản phẩm: ${form.id}</p></c:if>
        <label for="name">Tên sản phẩm</label>
        <input id="name" name="name" type="text" maxlength="255" required value="<c:out value='${form.name}'/>">
        <label for="price">Giá (VNĐ)</label>
        <input id="price" name="price" type="number" min="0" max="9999999999999.99" step="0.01" required value="<c:out value='${form.price}'/>">
        <label for="manufacturer">Nhà sản xuất</label>
        <input id="manufacturer" name="manufacturer" type="text" maxlength="255" required value="<c:out value='${form.manufacturer}'/>">
        <label for="description">Mô tả</label>
        <textarea id="description" name="description" rows="5" maxlength="2000"><c:out value="${form.description}"/></textarea>
        <div class="form-actions"><button type="submit">Lưu sản phẩm</button><a class="button secondary" href="<c:out value='${productsUrl}'/>">Huỷ</a></div>
    </form>
</div>
<%@ include file="fragments/footer.jspf" %>
