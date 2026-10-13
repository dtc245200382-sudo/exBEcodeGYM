package com.codegym.products.dao;

import com.codegym.products.model.Product;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ProductDAO {
    private final Database database;

    public ProductDAO(Database database) { this.database = database; }

    public List<Product> findAll() throws SQLException {
        List<Product> products = new ArrayList<>();
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT id, name, price, quantity FROM products ORDER BY id");
             ResultSet rows = statement.executeQuery()) {
            while (rows.next()) products.add(read(rows));
        }
        return products;
    }

    public Optional<Product> findById(int id) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT id, name, price, quantity FROM products WHERE id = ?")) {
            statement.setInt(1, id);
            try (ResultSet rows = statement.executeQuery()) {
                return rows.next() ? Optional.of(read(rows)) : Optional.empty();
            }
        }
    }

    public int insert(Product product) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "INSERT INTO products(name, price, quantity) VALUES (?, ?, ?)",
                     Statement.RETURN_GENERATED_KEYS)) {
            bind(statement, product);
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (!keys.next()) throw new SQLException("Missing generated product ID");
                return keys.getInt(1);
            }
        }
    }

    public boolean update(Product product) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement(
                     "UPDATE products SET name = ?, price = ?, quantity = ? WHERE id = ?")) {
            bind(statement, product);
            statement.setInt(4, product.getId());
            // Một số cấu hình JDBC trả về 0 nếu giá trị không thay đổi.
            return statement.executeUpdate() > 0 || exists(connection, product.getId());
        }
    }

    public boolean delete(int id) throws SQLException {
        try (Connection connection = database.connect();
             PreparedStatement statement = connection.prepareStatement("DELETE FROM products WHERE id = ?")) {
            statement.setInt(1, id);
            return statement.executeUpdate() > 0;
        }
    }

    private boolean exists(Connection connection, int id) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("SELECT id FROM products WHERE id = ?")) {
            statement.setInt(1, id);
            try (ResultSet rows = statement.executeQuery()) { return rows.next(); }
        }
    }

    private static void bind(PreparedStatement statement, Product product) throws SQLException {
        statement.setString(1, product.getName());
        statement.setBigDecimal(2, product.getPrice());
        statement.setInt(3, product.getQuantity());
    }

    private static Product read(ResultSet rows) throws SQLException {
        return new Product(rows.getInt("id"), rows.getString("name"),
                rows.getBigDecimal("price"), rows.getInt("quantity"));
    }
}
