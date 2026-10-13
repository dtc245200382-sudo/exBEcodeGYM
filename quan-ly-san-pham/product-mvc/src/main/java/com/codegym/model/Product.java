package com.codegym.model;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Đối tượng bất biến để dữ liệu trong Service không bị sửa từ bên ngoài. */
public final class Product {
    private final int id;
    private final String name;
    private final BigDecimal price;
    private final String description;
    private final String manufacturer;

    public Product(int id, String name, BigDecimal price, String description, String manufacturer) {
        if (id < 0) throw new IllegalArgumentException("ID sản phẩm không hợp lệ.");
        this.id = id;
        this.name = required(name, "Tên sản phẩm");
        this.manufacturer = required(manufacturer, "Nhà sản xuất");
        this.description = description == null ? "" : description.strip();
        if (this.description.length() > 2000)
            throw new IllegalArgumentException("Mô tả tối đa 2000 ký tự.");
        if (price == null || price.signum() < 0 || price.compareTo(new BigDecimal("9999999999999.99")) > 0)
            throw new IllegalArgumentException("Giá phải từ 0 đến 9999999999999.99.");
        try {
            this.price = price.setScale(2, RoundingMode.UNNECESSARY);
        } catch (ArithmeticException e) {
            throw new IllegalArgumentException("Giá chỉ được có tối đa 2 chữ số thập phân.");
        }
    }

    private static String required(String text, String label) {
        String value = text == null ? "" : text.strip();
        if (value.isEmpty() || value.length() > 255)
            throw new IllegalArgumentException(label + " phải có từ 1 đến 255 ký tự.");
        return value;
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public BigDecimal getPrice() { return price; }
    public String getDescription() { return description; }
    public String getManufacturer() { return manufacturer; }
}
