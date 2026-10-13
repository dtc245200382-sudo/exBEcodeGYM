<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<c:url value="/products" var="createUrl"><c:param name="action" value="create"/></c:url>
<div class="toolbar">
    <div><h1>Danh sách sản phẩm</h1><p class="muted">Quản lý thông tin và tìm kiếm sản phẩm theo tên.</p></div>
    <a class="button" href="<c:out value='${createUrl}'/>">+ Thêm sản phẩm</a>
</div>
<c:if test="${not empty message}"><p class="notice" role="status"><c:out value="${message}"/></p></c:if>
<form class="search" method="get" action="<c:out value='${productsUrl}'/>">
    <input type="hidden" name="action" value="search">
    <label for="keyword">Tên sản phẩm</label>
    <input id="keyword" name="keyword" type="search" placeholder="Nhập một phần tên sản phẩm" value="<c:out value='${keyword}'/>">
    <button type="submit">Tìm kiếm</button>
    <a href="<c:out value='${productsUrl}'/>">Xem tất cả</a>
</form>
<c:if test="${not empty keyword}"><p>Kết quả cho: <strong><c:out value="${keyword}"/></strong></p></c:if>
<div class="table-wrapper">
    <table>
        <caption class="visually-hidden">Danh sách sản phẩm và các thao tác quản lý</caption>
        <thead><tr><th scope="col">ID</th><th scope="col">Tên sản phẩm</th><th scope="col" class="number">Giá (VNĐ)</th><th scope="col">Mô tả</th><th scope="col">Nhà sản xuất</th><th scope="col">Thao tác</th></tr></thead>
        <tbody>
        <c:choose>
            <c:when test="${empty products}"><tr><td class="empty" colspan="6">Không có sản phẩm phù hợp.</td></tr></c:when>
            <c:otherwise>
                <c:forEach items="${products}" var="product">
                    <c:url value="/products" var="viewUrl"><c:param name="action" value="view"/><c:param name="id" value="${product.id}"/></c:url>
                    <c:url value="/products" var="editUrl"><c:param name="action" value="edit"/><c:param name="id" value="${product.id}"/></c:url>
                    <c:url value="/products" var="deleteUrl"><c:param name="action" value="delete"/><c:param name="id" value="${product.id}"/></c:url>
                    <tr data-product-id="${product.id}">
                        <td>${product.id}</td>
                        <td><a href="<c:out value='${viewUrl}'/>"><c:out value="${product.name}"/></a></td>
                        <td class="number"><c:out value="${product.price}"/></td>
                        <td class="description"><c:out value="${product.description}"/></td>
                        <td><c:out value="${product.manufacturer}"/></td>
                        <td class="actions"><a href="<c:out value='${viewUrl}'/>">Xem</a><a href="<c:out value='${editUrl}'/>">Sửa</a><a class="danger-link" href="<c:out value='${deleteUrl}'/>">Xoá</a></td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>
<%@ include file="fragments/footer.jspf" %>
