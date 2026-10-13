package com.codegym.service;

import com.codegym.model.Product;
import java.util.List;

public interface ProductService {
    List<Product> findAll();
    Product findById(int id);
    /** Tự cấp ID cho sản phẩm có ID đầu vào bằng 0. */
    Product save(Product product);
    /** Trả về false nếu sản phẩm cần sửa không còn tồn tại. */
    boolean update(int id, Product product);
    boolean remove(int id);
    List<Product> searchByName(String keyword);
}
