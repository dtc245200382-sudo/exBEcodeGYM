<%@ page pageEncoding="UTF-8" %>
<%@ include file="fragments/header.jspf" %>
<div class="narrow">
    <h1>Không thể thực hiện yêu cầu</h1>
    <p class="error" role="alert"><c:out value="${errorMessage}"/></p>
    <a class="button" href="<c:out value='${productsUrl}'/>">Về danh sách sản phẩm</a>
</div>
<%@ include file="fragments/footer.jspf" %>
