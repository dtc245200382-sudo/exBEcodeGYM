package com.codegym.products.web;

import com.codegym.products.model.Product;
import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.Map;

/** Giữ dữ liệu gốc để hiển thị lại biểu mẫu khi nhập sai. */
public class ProductForm {
    private final int id;
    private final String name;
    private final String price;
    private final String quantity;

    public ProductForm(int id, String name, String price, String quantity) {
        this.id = id;
        this.name = name == null ? "" : name;
        this.price = price == null ? "" : price;
        this.quantity = quantity == null ? "" : quantity;
    }

    public static ProductForm empty() { return new ProductForm(0, "", "", ""); }
    public static ProductForm from(Product product) {
        return new ProductForm(product.getId(), product.getName(),
                product.getPrice().toPlainString(), Integer.toString(product.getQuantity()));
    }

    public Map<String, String> validate() {
        Map<String, String> errors = new LinkedHashMap<>();
        String cleanName = name.strip();
        if (cleanName.isEmpty() || cleanName.codePointCount(0, cleanName.length()) > 255)
            errors.put("name", "Tên sản phẩm phải có từ 1 đến 255 ký tự.");
        String cleanPrice = price.strip();
        if (cleanPrice.length() > 32 || !cleanPrice.matches("[0-9]+(?:\\.[0-9]{1,2})?")) {
            errors.put("price", "Giá phải là số không âm, tối đa 2 chữ số thập phân (dùng dấu chấm).");
        } else if (new BigDecimal(cleanPrice).compareTo(new BigDecimal("9999999999999.99")) > 0) {
            errors.put("price", "Giá vượt quá giới hạn 9.999.999.999.999,99.");
        }
        try {
            String cleanQuantity = quantity.strip();
            if (!cleanQuantity.matches("[0-9]{1,10}") || Integer.parseInt(cleanQuantity) < 0)
                throw new NumberFormatException();
        } catch (NumberFormatException e) {
            errors.put("quantity", "Số lượng phải là số nguyên từ 0 đến 2147483647.");
        }
        return errors;
    }

    public Product toProduct() {
        if (!validate().isEmpty()) throw new IllegalArgumentException("Invalid product form");
        return new Product(id, name.strip(), new BigDecimal(price.strip()).setScale(2),
                Integer.parseInt(quantity.strip()));
    }

    public int getId() { return id; }
    public String getName() { return name; }
    public String getPrice() { return price; }
    public String getQuantity() { return quantity; }
}
