package com.codegym.controller;

import com.codegym.model.Product;
import com.codegym.service.ProductService;
import com.codegym.service.ProductServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.UUID;

public class ProductServlet extends HttpServlet {
    private final ProductService productService = new ProductServiceImpl();

    @Override protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        try {
            switch (action(request, "list")) {
                case "list", "search" -> {
                    String keyword = request.getParameter("keyword");
                    keyword = keyword == null ? "" : keyword.strip();
                    request.setAttribute("keyword", keyword);
                    request.setAttribute("products", productService.searchByName(keyword));
                    request.setAttribute("message", request.getSession().getAttribute("message"));
                    request.getSession().removeAttribute("message");
                    render("list", "Danh sách sản phẩm", request, response);
                }
                case "create" -> {
                    request.setAttribute("form", ProductForm.empty());
                    render("form", "Thêm sản phẩm", request, response);
                }
                case "edit", "delete", "view" -> {
                    Product product = productService.findById(id(request));
                    if (product == null) {
                        error(404, "Không tìm thấy sản phẩm.", request, response);
                        return;
                    }
                    request.setAttribute("product", product);
                    switch (action(request, "")) {
                        case "edit" -> {
                            request.setAttribute("form", ProductForm.from(product));
                            render("form", "Sửa sản phẩm", request, response);
                        }
                        case "delete" -> render("delete", "Xác nhận xoá sản phẩm", request, response);
                        case "view" -> render("view", "Chi tiết sản phẩm", request, response);
                    }
                }
                default -> error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        }
    }

    @Override protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepare(request, response);
        String token = request.getParameter("csrf");
        if (token == null || !token.equals(request.getSession().getAttribute("csrf"))) {
            error(403, "Phiên biểu mẫu không hợp lệ. Hãy mở lại trang và thử lại.", request, response);
            return;
        }
        try {
            switch (action(request, "")) {
                case "create", "edit" -> save(request, response);
                case "delete" -> {
                    if (!"yes".equals(request.getParameter("confirmed"))) {
                        error(400, "Bạn cần xác nhận trước khi xoá sản phẩm.", request, response);
                    } else if (productService.remove(id(request))) {
                        success("Đã xoá sản phẩm.", request, response);
                    } else {
                        error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
                    }
                }
                default -> error(400, "Thao tác không hợp lệ.", request, response);
            }
        } catch (IllegalArgumentException e) {
            error(400, "Mã sản phẩm không hợp lệ.", request, response);
        }
    }

    private void save(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        boolean editing = "edit".equals(request.getParameter("action"));
        int productId = editing ? id(request) : 0;
        ProductForm form = new ProductForm(productId, request.getParameter("name"),
                request.getParameter("price"), request.getParameter("description"), request.getParameter("manufacturer"));
        Product product;
        try {
            product = form.toProduct();
        } catch (IllegalArgumentException e) {
            response.setStatus(400);
            request.setAttribute("form", form);
            request.setAttribute("errorMessage", e.getMessage());
            render("form", editing ? "Sửa sản phẩm" : "Thêm sản phẩm", request, response);
            return;
        }
        if (!editing) {
            productService.save(product);
            success("Đã thêm sản phẩm.", request, response);
        } else if (productService.update(productId, product)) {
            success("Đã cập nhật sản phẩm.", request, response);
        } else {
            error(404, "Sản phẩm đã bị xoá hoặc không tồn tại.", request, response);
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
        String action = request.getParameter("action");
        return action == null ? fallback : action;
    }

    private static int id(HttpServletRequest request) {
        int id = Integer.parseInt(request.getParameter("id"));
        if (id <= 0) throw new IllegalArgumentException("Invalid ID");
        return id;
    }

    private static void render(String view, String title, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("pageTitle", title);
        request.getRequestDispatcher("/WEB-INF/views/" + view + ".jsp").forward(request, response);
    }

    private static void success(String message, HttpServletRequest request, HttpServletResponse response) {
        request.getSession().setAttribute("message", message);
        response.setStatus(HttpServletResponse.SC_SEE_OTHER);
        response.setHeader("Location", request.getContextPath() + "/products");
    }

    private static void error(int status, String message, HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(status);
        request.setAttribute("errorMessage", message);
        render("error", "Không thể thực hiện yêu cầu", request, response);
    }
}
