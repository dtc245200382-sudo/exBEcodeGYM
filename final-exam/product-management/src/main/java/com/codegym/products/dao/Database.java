package com.codegym.products.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Database {
    private final String url;
    private final String user;
    private final String password;

    public Database() {
        url = environment("PRODUCT_DB_URL",
                "jdbc:mysql://localhost:3306/product_management_db?characterEncoding=UTF-8&serverTimezone=Asia/Ho_Chi_Minh");
        user = environment("PRODUCT_DB_USER", "root");
        password = environment("PRODUCT_DB_PASSWORD", "");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("MySQL Connector/J is missing", e);
        }
    }

    private static String environment(String name, String fallback) {
        String value = System.getenv(name);
        return value == null ? fallback : value;
    }

    public Connection connect() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}
