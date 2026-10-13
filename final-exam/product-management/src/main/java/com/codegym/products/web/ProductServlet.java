package com.codegym.products.web;

import com.codegym.products.dao.Database;
import com.codegym.products.dao.ProductDAO;
import com.codegym.products.model.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

public class ProductServlet extends HttpServlet {
    private ProductDAO dao;

    @Override public void init() { dao = new ProductDAO(new Database()); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        try {
            switch (action(request, "list")) {
                case "list" -> {
                    request.setAttribute("products", dao.findAll());
                    HttpSession session = request.getSession();
                    request.setAttribute("message", session.getAttribute("message"));
                    session.removeAttribute("message");
                    render("list", request, response);
                }
                case "create" -> {
                    request.setAttribute("form", ProductForm.empty());
                    render("form", request, response);
                }
                case "edit", "confirm-delete" -> {
                    Optional<Product> product = dao.findById(id(request));
                    if (product.isEmpty()) {
                        error(404, "Không tìm thấy sản phẩm.", request, response);
                    } else if ("edit".equals(request.getParameter("action"))) {
                        request.setAttribute("form", ProductForm.from(product.get()));
                        render("form", request, response);
                    } else {
                        request.setAttribute("product", product.get());
                        render("delete", request, response);
                    }
                }
                default -> error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        } catch (SQLException e) {
            databaseError(request, response, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        String token = request.getParameter("csrf");
        if (token == null || !token.equals(request.getSession().getAttribute("csrf"))) {
            error(403, "Phiên biểu mẫu không hợp lệ. Hãy mở lại trang và thử lại.", request, response);
            return;
        }
        try {
            String action = action(request, "");
            if ("create".equals(action) || "update".equals(action)) {
                int productId = "update".equals(action) ? id(request) : 0;
                ProductForm form = new ProductForm(productId, request.getParameter("name"),
                        request.getParameter("price"), request.getParameter("quantity"));
                Map<String, String> errors = form.validate();
                if (!errors.isEmpty()) {
                    response.setStatus(400);
                    request.setAttribute("form", form);
                    request.setAttribute("errors", errors);
                    render("form", request, response);
                    return;
                }
                if (productId == 0) {
                    dao.insert(form.toProduct());
                    success("Đã thêm sản phẩm.", request, response);
                } else if (dao.update(form.toProduct())) {
                    success("Đã cập nhật sản phẩm.", request, response);
                } else {
                    error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
                }
            } else if ("delete".equals(action)) {
                if (!"yes".equals(request.getParameter("confirmed"))) {
                    error(400, "Bạn cần xác nhận trước khi xoá sản phẩm.", request, response);
                } else if (dao.delete(id(request))) {
                    success("Đã xoá sản phẩm.", request, response);
                } else {
                    error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
                }
            } else {
                error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        } catch (SQLException e) {
            databaseError(request, response, e);
        }
    }

    private static void prepare(HttpServletRequest request, HttpServletResponse response)
            throws java.io.UnsupportedEncodingException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("X-Content-Type-Options", "nosniff");
        HttpSession session = request.getSession();
        synchronized (session) {
            if (session.getAttribute("csrf") == null)
                session.setAttribute("csrf", UUID.randomUUID().toString());
        }
    }

    private static String action(HttpServletRequest request, String fallback) {
        String value = request.getParameter("action");
        return value == null ? fallback : value;
    }

    private static int id(HttpServletRequest request) {
        int value = Integer.parseInt(request.getParameter("id"));
        if (value <= 0) throw new IllegalArgumentException("Invalid ID");
        return value;
    }

    private static void render(String view, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(request, response);
    }

    private static void success(String message, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        request.getSession().setAttribute("message", message);
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.setHeader("Location", request.getContextPath() + "/products");
    }

    private static void error(int status, String message, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("errorMessage", message);
        render("error", request, response);
    }

    private void databaseError(HttpServletRequest request, HttpServletResponse response, SQLException e)
            throws ServletException, IOException {
        getServletContext().log("Product database operation failed", e);
        error(500, "Không thể truy cập dữ liệu. Hãy kiểm tra MySQL và cấu hình kết nối của ứng dụng.",
                request, response);
    }
}
