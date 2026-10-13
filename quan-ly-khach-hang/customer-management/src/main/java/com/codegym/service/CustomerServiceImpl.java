package com.codegym.service;

import com.codegym.model.Customer;
import java.util.List;
import java.util.Map;

/**
 * Khung triển khai Service với Map tĩnh giả lập cơ sở dữ liệu.
 * Học viên tự khởi tạo Map, thêm dữ liệu mẫu và triển khai các phương thức.
 * Dữ liệu Map chỉ tồn tại trong bộ nhớ khi ứng dụng đang chạy.
 * Lớp abstract giúp khung chữ ký biên dịch được mà chưa có logic nghiệp vụ.
 */
public abstract class CustomerServiceImpl implements CustomerService {
    private static Map<Integer, Customer> customers;

    @Override public abstract List<Customer> findAll();
    @Override public abstract void save(Customer customer);
    @Override public abstract Customer findById(int id);
    @Override public abstract void update(int id, Customer customer);
    @Override public abstract void remove(int id);
}
