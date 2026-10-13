package com.codegym.model;

/**
 * Khung Model khách hàng gồm id, name, email và address.
 * Học viên tự viết constructor, getter và setter theo mã tham khảo trong đề.
 * Các phương thức abstract chỉ khai báo chữ ký, không chứa logic.
 * Khi hoàn thiện, bỏ abstract và bổ sung thân các phương thức.
 */
public abstract class Customer {
    private int id;
    private String name;
    private String email;
    private String address;

    public abstract int getId();
    public abstract void setId(int id);
    public abstract String getName();
    public abstract void setName(String name);
    public abstract String getEmail();
    public abstract void setEmail(String email);
    public abstract String getAddress();
    public abstract void setAddress(String address);
}
