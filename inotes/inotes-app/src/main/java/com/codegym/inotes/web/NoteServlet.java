package com.codegym.inotes.web;

import com.codegym.inotes.model.Note;
import com.codegym.inotes.model.NoteType;
import com.codegym.inotes.service.NoteManagement;
import com.codegym.inotes.storage.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.nio.file.Path;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public class NoteServlet extends HttpServlet {
    private NoteStrategy fileStorage;
    private NoteStrategy databaseStorage;

    private static String environment(String key, String fallback) {
        String value = System.getenv(key);
        return value == null ? fallback : value;
    }

    @Override
    public void init() {
        Path directory = Path.of(environment("INOTES_DATA_DIR",
                Path.of(System.getProperty("catalina.base", System.getProperty("user.dir")), "inotes-data").toString()));
        fileStorage = new NoteFileStrategy(directory);
        databaseStorage = new NoteDBStrategy(
                environment("INOTES_DB_URL", "jdbc:mysql://127.0.0.1:3306/inotes_db?characterEncoding=UTF-8&connectTimeout=3000&socketTimeout=5000"),
                environment("INOTES_DB_USER", "root"), environment("INOTES_DB_PASSWORD", ""));
    }

    private NoteManagement management(HttpSession session) {
        NoteManagement management = (NoteManagement) session.getAttribute("management");
        if (management == null) {
            management = new NoteManagement(fileStorage);
            session.setAttribute("management", management);
        }
        if (session.getAttribute("csrf") == null) session.setAttribute("csrf", UUID.randomUUID().toString());
        return management;
    }

    private static int number(String value, int fallback) {
        if (value == null || value.isBlank()) return fallback;
        try { return Integer.parseInt(value); }
        catch (NumberFormatException e) { throw new IllegalArgumentException("Mã số không hợp lệ."); }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession();
        synchronized (session) {
            NoteManagement management = management(session);
            String action = request.getParameter("action");
            if (action == null) action = "list";
            if (!Set.of("list", "new", "edit", "view").contains(action)) { response.sendError(400); return; }
            String keyword = request.getParameter("q");
            if (keyword == null) keyword = "";
            if (keyword.length() > 200) { response.sendError(400, "Từ khoá tối đa 200 ký tự."); return; }
            int type;
            try { type = number(request.getParameter("type"), 0); }
            catch (IllegalArgumentException e) { response.sendError(400); return; }
            request.setAttribute("mode", action);
            request.setAttribute("keyword", keyword);
            request.setAttribute("typeFilter", type);
            request.setAttribute("storage", management.storageName());
            String[] flash = (String[]) session.getAttribute("flash");
            session.removeAttribute("flash");
            if (flash != null) {
                request.setAttribute("message", flash[1]);
                request.setAttribute("messageError", "error".equals(flash[0]));
            }
            try {
                List<NoteType> types = management.findTypes();
                List<Note> notes = management.searchNotes(keyword);
                if (type > 0) notes = notes.stream().filter(note -> note.getTypeId() == type).toList();
                request.setAttribute("types", types);
                request.setAttribute("notes", notes);
                if (action.equals("edit") || action.equals("view"))
                    request.setAttribute("selected", management.findById(number(request.getParameter("id"), 0)));
            } catch (IllegalArgumentException e) { response.sendError(404, "Không tìm thấy ghi chú."); return; }
            catch (StorageException e) {
                getServletContext().log("iNotes storage read failed", e);
                request.setAttribute("types", List.of());
                request.setAttribute("notes", List.of());
                request.setAttribute("mode", "list");
                request.setAttribute("messageError", true);
                request.setAttribute("message", "Không đọc được kho dữ liệu. Kiểm tra cấu hình hoặc chuyển sang File.");
                response.setStatus(503);
            }
            request.getRequestDispatcher("/WEB-INF/views/notes.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null) { response.sendError(403, "Vui lòng tải lại trang."); return; }
        synchronized (session) {
            NoteManagement management = management(session);
            String csrf = (String) session.getAttribute("csrf");
            if (!csrf.equals(request.getParameter("csrf"))) { response.sendError(403, "Yêu cầu không hợp lệ."); return; }
            try {
                String action = request.getParameter("action");
                if ("switch".equals(action)) {
                    String storage = request.getParameter("storage");
                    NoteStrategy candidate;
                    if ("file".equals(storage)) candidate = fileStorage;
                    else if ("mysql".equals(storage)) candidate = databaseStorage;
                    else throw new IllegalArgumentException("Kho dữ liệu không hợp lệ.");
                    // Thử truy cập trước; thất bại không thay đổi chiến lược hiện tại.
                    candidate.findTypes();
                    candidate.findAll();
                    management.setStrategy(candidate);
                    session.setAttribute("flash", new String[]{"success", "Đã chuyển sang " + (storage.equals("file") ? "File" : "MySQL") + "."});
                } else {
                    if (!management.storageName().equals(request.getParameter("_storage")))
                        throw new IllegalArgumentException("Kho dữ liệu đã đổi. Vui lòng tải lại form trước khi lưu hoặc xoá.");
                    if ("save".equals(action)) {
                        management.saveNote(number(request.getParameter("id"), 0), request.getParameter("title"),
                                request.getParameter("content"), number(request.getParameter("typeId"), 0));
                        session.setAttribute("flash", new String[]{"success", "Đã lưu ghi chú."});
                    } else if ("delete".equals(action)) {
                        management.deleteNote(number(request.getParameter("id"), 0));
                        session.setAttribute("flash", new String[]{"success", "Đã xoá ghi chú."});
                    } else throw new IllegalArgumentException("Thao tác không hợp lệ.");
                }
            } catch (IllegalArgumentException e) { session.setAttribute("flash", new String[]{"error", e.getMessage()}); }
            catch (StorageException e) {
                getServletContext().log("iNotes storage write/switch failed", e);
                session.setAttribute("flash", new String[]{"error", "Không truy cập được kho dữ liệu. Kiểm tra file hoặc cấu hình MySQL; thao tác chưa hoàn tất."});
            }
            response.sendRedirect(request.getContextPath() + "/notes");
        }
    }
}
