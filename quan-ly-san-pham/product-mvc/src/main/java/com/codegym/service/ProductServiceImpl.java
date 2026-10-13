package com.codegym.service;

import com.codegym.model.Product;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/** Map tĩnh giả lập dữ liệu, dùng chung cho các phiên trong cùng ứng dụng. */
public class ProductServiceImpl implements ProductService {
    private static final Map<Integer, Product> products = new LinkedHashMap<>();
    private static int nextId = 6;

    static {
        products.put(1, new Product(1, "Bàn phím cơ", new BigDecimal("750000"), "Bàn phím có đèn nền và kết nối USB.", "KeyPro"));
        products.put(2, new Product(2, "Chuột không dây", new BigDecimal("250000"), "Chuột dùng kết nối Bluetooth.", "TechMouse"));
        products.put(3, new Product(3, "Màn hình 24 inch", new BigDecimal("3200000"), "Màn hình Full HD phục vụ học tập và làm việc.", "ViewMax"));
        products.put(4, new Product(4, "Tai nghe", new BigDecimal("450000"), "Tai nghe có micro tích hợp.", "SoundOne"));
        products.put(5, new Product(5, "Bàn phím không dây", new BigDecimal("550000"), "Bàn phím nhỏ gọn cho máy tính xách tay.", "KeyPro"));
    }

    @Override public List<Product> findAll() {
        synchronized (products) { return new ArrayList<>(products.values()); }
    }

    @Override public Product findById(int id) {
        synchronized (products) { return products.get(id); }
    }

    @Override public Product save(Product product) {
        if (product == null || product.getId() != 0)
            throw new IllegalArgumentException("Sản phẩm mới phải chưa có ID.");
        synchronized (products) {
            if (nextId == Integer.MAX_VALUE) throw new IllegalStateException("Đã hết ID sản phẩm.");
            Product saved = withId(nextId++, product);
            products.put(saved.getId(), saved);
            return saved;
        }
    }

    @Override public boolean update(int id, Product product) {
        if (product == null || product.getId() != id)
            throw new IllegalArgumentException("ID sản phẩm cập nhật không khớp.");
        synchronized (products) {
            if (!products.containsKey(id)) return false;
            products.put(id, product);
            return true;
        }
    }

    @Override public boolean remove(int id) {
        synchronized (products) { return products.remove(id) != null; }
    }

    @Override public List<Product> searchByName(String keyword) {
        String text = keyword == null ? "" : keyword.strip().toLowerCase(Locale.ROOT);
        return findAll().stream()
                .filter(product -> product.getName().toLowerCase(Locale.ROOT).contains(text))
                .toList();
    }

    private static Product withId(int id, Product product) {
        return new Product(id, product.getName(), product.getPrice(),
                product.getDescription(), product.getManufacturer());
    }
}
