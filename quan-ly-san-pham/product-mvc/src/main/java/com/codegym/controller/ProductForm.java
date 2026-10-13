package com.codegym.controller;

import com.codegym.model.Product;
import java.math.BigDecimal;

/** Giữ dữ liệu gốc để biểu mẫu không bị mất nội dung khi nhập sai. */
public class ProductForm {
    private final int id;
    private final String name;
    private final String price;
    private final String description;
    private final String manufacturer;

    public ProductForm(int id, String name, String price, String description, String manufacturer) {
        this.id = id;
        this.name = text(name);
        this.price = text(price);
        this.description = text(description);
        this.manufacturer = text(manufacturer);
    }

    public static ProductForm empty() { return new ProductForm(0, "", "", "", ""); }
    public static ProductForm from(Product product) {
        return new ProductForm(product.getId(), product.getName(), product.getPrice().toPlainString(),
                product.getDescription(), product.getManufacturer());
    }

    public Product toProduct() {
        String cleanPrice = price.strip();
        if (cleanPrice.length() > 32 || !cleanPrice.matches("[0-9]+(?:\\.[0-9]{1,2})?"))
            throw new IllegalArgumentException("Giá phải là số không âm, tối đa 2 chữ số thập phân (dùng dấu chấm).");
        return new Product(id, name, new BigDecimal(cleanPrice), description, manufacturer);
    }

    private static String text(String value) { return value == null ? "" : value; }
    public int getId() { return id; }
    public String getName() { return name; }
    public String getPrice() { return price; }
    public String getDescription() { return description; }
    public String getManufacturer() { return manufacturer; }
}
