<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,com.codegym.inotes.model.*,com.codegym.inotes.web.Html" %>
<%
    List<Note> notes = (List<Note>) request.getAttribute("notes");
    List<NoteType> types = (List<NoteType>) request.getAttribute("types");
    Map<Integer, String> typeNames = new HashMap<>();
    for (NoteType type : types) typeNames.put(type.id(), type.name());
    String mode = (String) request.getAttribute("mode");
    String storage = (String) request.getAttribute("storage");
    String csrf = (String) session.getAttribute("csrf");
    String keyword = (String) request.getAttribute("keyword");
    int typeFilter = (Integer) request.getAttribute("typeFilter");
    String message = (String) request.getAttribute("message");
    boolean messageError = Boolean.TRUE.equals(request.getAttribute("messageError"));
    Note selected = (Note) request.getAttribute("selected");
    String base = request.getContextPath() + "/notes";
%>
<!doctype html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>iNotes — Quản lý ghi chú</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; background: #f5f7fa; color: #26354b; font-family: Arial, sans-serif; }
        .container { max-width: 1050px; margin: 32px auto; padding: 0 20px; }
        .top, .storage, .toolbar, .actions { display: flex; align-items: center; flex-wrap: wrap; gap: 12px; }
        .top { justify-content: space-between; margin-bottom: 20px; }
        h1 { margin: 0 0 6px; font-size: 34px; }
        h2 { margin: 0 0 24px; font-size: 24px; }
        p { line-height: 1.6; }
        .muted { color: #6d7b8e; font-size: 14px; margin: 0; }
        .storage { border: 1px solid #dce3ed; padding: 12px; border-radius: 8px; background: white; }
        .card { background: white; border: 1px solid #e0e5ed; border-radius: 10px; padding: 24px; margin: 20px 0; }
        .notice { margin: 16px 0; padding: 14px; border-radius: 6px; background: #e8f4ee; color: #286547; }
        .notice.error { background: #fff0f0; color: #9f2834; }
        input, select, textarea, button { font: inherit; }
        input, select, textarea { max-width: 100%; padding: 10px 12px; border: 1px solid #cbd5e1; border-radius: 5px; background: white; color: inherit; }
        input:focus-visible, select:focus-visible, textarea:focus-visible, button:focus-visible, a:focus-visible { outline: 2px solid #4571c4; outline-offset: 2px; }
        .btn, button { display: inline-block; padding: 10px 14px; border: 1px solid #315fb1; border-radius: 5px; background: #315fb1; color: white; text-decoration: none; cursor: pointer; }
        .btn.secondary { border-color: #cbd5e1; background: white; color: #41546e; }
        button:disabled { opacity: .5; cursor: not-allowed; }
        .toolbar input { flex: 1 1 220px; min-width: 0; }
        .table-wrapper { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; margin-top: 22px; }
        th, td { text-align: left; padding: 15px 10px; border-bottom: 1px solid #edf0f4; }
        th { font-size: 13px; color: #6d7b8e; }
        .title-cell { max-width: 420px; overflow-wrap: anywhere; }
        .badge { display: inline-block; padding: 5px 8px; border-radius: 20px; font-size: 12px; color: #4166a2; background: #eef3fb; white-space: nowrap; }
        .actions { gap: 10px; }
        .actions a { color: #315fb1; font-size: 14px; text-decoration: none; }
        .actions a:hover { text-decoration: underline; }
        .actions form { margin: 0; }
        .delete { padding: 0; border: 0; background: transparent; color: #a53442; font-size: 14px; }
        .field { margin-bottom: 20px; }
        .field label { display: block; margin-bottom: 8px; font-size: 14px; font-weight: bold; }
        .field input, .field select, .field textarea { width: 100%; }
        textarea { min-height: 200px; resize: vertical; line-height: 1.6; }
        .note-content { white-space: pre-wrap; overflow-wrap: anywhere; line-height: 1.8; font-family: inherit; margin: 24px 0; }
        .empty { padding: 28px 0; text-align: center; color: #6d7b8e; }
        footer { text-align: center; font-size: 12px; color: #7a8799; margin: 24px 0; }
        @media(max-width: 600px) { .container { padding: 0 12px; margin-top: 20px; } .card { padding: 16px; } .storage { width: 100%; } .toolbar > select { width: 100%; } th, td { padding: 12px 7px; } }
    </style>
</head>
<body>
    <main class="container">
        <div class="top">
            <div><h1>iNotes</h1><p class="muted">Ghi lại điều quan trọng, tìm lại khi cần.</p></div>
            <form class="storage" action="<%= base %>" method="post">
                <input type="hidden" name="csrf" value="<%= csrf %>">
                <input type="hidden" name="action" value="switch">
                <label for="storage">Kho dữ liệu</label>
                <select id="storage" name="storage">
                    <option value="file" <%= "file".equals(storage) ? "selected" : "" %>>File</option>
                    <option value="mysql" <%= "mysql".equals(storage) ? "selected" : "" %>>MySQL</option>
                </select>
                <button type="submit">Chuyển kho</button>
            </form>
        </div>
        <p class="muted" id="active-storage">Đang dùng: <strong><%= "mysql".equals(storage) ? "MySQL" : "File" %></strong>. Hai kho lưu riêng; chuyển kho không tự sao chép ghi chú.</p>
        <% if (message != null) { %>
            <div class="notice <%= messageError ? "error" : "" %>" role="status"><%= Html.escape(message) %></div>
        <% } %>

        <% if ("new".equals(mode) || "edit".equals(mode)) { %>
            <div class="card">
                <h2><%= selected == null ? "Thêm mới ghi chú" : "Sửa ghi chú" %></h2>
                <form action="<%= base %>" method="post">
                    <input type="hidden" name="csrf" value="<%= csrf %>">
                    <input type="hidden" name="_storage" value="<%= storage %>">
                    <input type="hidden" name="action" value="save">
                    <input type="hidden" name="id" value="<%= selected == null ? 0 : selected.getId() %>">
                    <div class="field"><label for="title">Tiêu đề</label><input id="title" name="title" maxlength="255" value="<%= Html.escape(selected == null ? "" : selected.getTitle()) %>" required autofocus></div>
                    <div class="field"><label for="typeId">Phân loại</label><select id="typeId" name="typeId" required>
                        <% for (NoteType type : types) { %>
                            <option value="<%= type.id() %>" <%= selected != null && selected.getTypeId() == type.id() ? "selected" : "" %>><%= Html.escape(type.name()) %></option>
                        <% } %>
                    </select></div>
                    <div class="field"><label for="content">Nội dung</label><textarea id="content" name="content" maxlength="10000"><%= Html.escape(selected == null ? "" : selected.getContent()) %></textarea></div>
                    <div class="actions"><button type="submit" <%= types.isEmpty() ? "disabled" : "" %>>Lưu ghi chú</button><a class="btn secondary" href="<%= base %>">Huỷ bỏ</a></div>
                </form>
            </div>
        <% } else if ("view".equals(mode) && selected != null) { %>
            <div class="card">
                <h2><%= Html.escape(selected.getTitle()) %></h2>
                <span class="badge"><%= Html.escape(typeNames.get(selected.getTypeId())) %></span>
                <pre class="note-content"><%= Html.escape(selected.getContent()) %></pre>
                <div class="actions"><a class="btn" href="<%= base %>?action=edit&amp;id=<%= selected.getId() %>">Sửa ghi chú</a><a class="btn secondary" href="<%= base %>">Về danh sách</a></div>
            </div>
        <% } else { %>
            <div class="card">
                <div class="top"><h2 class="muted">Danh sách ghi chú (<%= notes.size() %>)</h2><a class="btn" href="<%= base %>?action=new">+ Thêm mới</a></div>
                <form class="toolbar" action="<%= base %>" method="get">
                    <input name="q" type="search" value="<%= Html.escape(keyword) %>" maxlength="200" placeholder="Tìm trong tiêu đề hoặc nội dung…" aria-label="Tìm kiếm ghi chú">
                    <select name="type" aria-label="Lọc theo phân loại"><option value="0">Tất cả phân loại</option>
                        <% for (NoteType type : types) { %><option value="<%= type.id() %>" <%= typeFilter == type.id() ? "selected" : "" %>><%= Html.escape(type.name()) %></option><% } %>
                    </select>
                    <button type="submit">Tìm kiếm</button><a class="btn secondary" href="<%= base %>">Đặt lại</a>
                </form>
                <% if (notes.isEmpty()) { %><p class="empty">Chưa có ghi chú hoặc không tìm thấy kết quả phù hợp.</p><% } else { %>
                    <div class="table-wrapper"><table>
                        <thead><tr><th>#</th><th>Tiêu đề</th><th>Phân loại</th><th>Thao tác</th></tr></thead>
                        <tbody><% for (Note note : notes) { %><tr data-note-id="<%= note.getId() %>">
                            <td><%= note.getId() %></td><td class="title-cell"><%= Html.escape(note.getTitle()) %></td>
                            <td><span class="badge"><%= Html.escape(typeNames.get(note.getTypeId())) %></span></td>
                            <td><div class="actions">
                                <a href="<%= base %>?action=view&amp;id=<%= note.getId() %>">Xem</a>
                                <a href="<%= base %>?action=edit&amp;id=<%= note.getId() %>">Sửa</a>
                                <form action="<%= base %>" method="post" onsubmit="return confirm('Xoá ghi chú này?');">
                                    <input type="hidden" name="csrf" value="<%= csrf %>"><input type="hidden" name="_storage" value="<%= storage %>">
                                    <input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<%= note.getId() %>">
                                    <button class="delete" type="submit">Xoá</button>
                                </form>
                            </div></td>
                        </tr><% } %></tbody>
                    </table></div>
                <% } %>
            </div>
        <% } %>
        <footer>iNotes · Java Servlet/JSP · Strategy Pattern</footer>
    </main>
</body>
</html>
