package com.codegym.service;

import com.codegym.model.Customer;
import java.util.List;

/** Hợp đồng của tầng Service; không chứa phần triển khai nghiệp vụ. */
public interface CustomerService {
    /** Trả về danh sách khách hàng. */
    List<Customer> findAll();

    /** Lưu một khách hàng mới. */
    void save(Customer customer);

    /** Tìm khách hàng theo ID; quy ước trả về null khi không tồn tại. */
    Customer findById(int id);

    /** Cập nhật khách hàng đã có theo ID. */
    void update(int id, Customer customer);

    /** Xoá khách hàng theo ID. */
    void remove(int id);
}
