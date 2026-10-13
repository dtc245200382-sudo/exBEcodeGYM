package com.codegym.inotes.storage;

import com.codegym.inotes.model.Note;
import com.codegym.inotes.model.NoteType;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class NoteDBStrategy implements NoteStrategy {
    private final String url;
    private final String user;
    private final String password;

    public NoteDBStrategy(String url, String user, String password) {
        this.url = url;
        this.user = user;
        this.password = password;
        try { Class.forName("com.mysql.cj.jdbc.Driver"); }
        catch (ClassNotFoundException e) { throw new StorageException("Thiếu MySQL Connector/J.", e); }
    }

    private Connection connect() throws SQLException { return DriverManager.getConnection(url, user, password); }
    @Override public String name() { return "mysql"; }

    @Override
    public void save(Note note) {
        note.validate();
        try (Connection connection = connect()) {
            try (PreparedStatement type = connection.prepareStatement("SELECT id FROM note_type WHERE id = ?")) {
                type.setInt(1, note.getTypeId());
                try (ResultSet rs = type.executeQuery()) {
                    if (!rs.next()) throw new IllegalArgumentException("Phân loại không tồn tại.");
                }
            }
            boolean creating = note.getId() == 0;
            String sql = creating ? "INSERT INTO notes(title, content, type_id) VALUES (?, ?, ?)"
                    : "UPDATE notes SET title = ?, content = ?, type_id = ? WHERE id = ?";
            try (PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                statement.setString(1, note.getTitle());
                statement.setString(2, note.getContent());
                statement.setInt(3, note.getTypeId());
                if (!creating) statement.setInt(4, note.getId());
                int affected = statement.executeUpdate();
                if (!creating && affected == 0 && !exists(connection, note.getId()))
                    throw new IllegalArgumentException("Không tìm thấy ghi chú cần sửa.");
                if (creating) {
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) throw new SQLException("Missing generated note ID");
                        note.setId(keys.getInt(1));
                    }
                }
            }
        } catch (SQLException e) { throw new StorageException("Không lưu được ghi chú vào MySQL.", e); }
    }

    private boolean exists(Connection connection, int id) throws SQLException {
        try (PreparedStatement statement = connection.prepareStatement("SELECT id FROM notes WHERE id = ?")) {
            statement.setInt(1, id);
            try (ResultSet rs = statement.executeQuery()) { return rs.next(); }
        }
    }

    @Override
    public void delete(int id) {
        if (id <= 0) throw new IllegalArgumentException("ID không hợp lệ.");
        try (Connection connection = connect(); PreparedStatement statement = connection.prepareStatement("DELETE FROM notes WHERE id = ?")) {
            statement.setInt(1, id);
            if (statement.executeUpdate() == 0) throw new IllegalArgumentException("Không tìm thấy ghi chú cần xoá.");
        } catch (SQLException e) { throw new StorageException("Không xoá được ghi chú trong MySQL.", e); }
    }

    @Override public List<Note> findAll() { return query("SELECT id, title, content, type_id FROM notes ORDER BY id DESC", null); }

    @Override
    public List<Note> search(String keyword) {
        String value = keyword == null ? "" : keyword.strip();
        if (value.isEmpty()) return findAll();
        String pattern = "%" + value.replace("!", "!!").replace("%", "!%").replace("_", "!_") + "%";
        return query("SELECT id, title, content, type_id FROM notes WHERE title LIKE ? ESCAPE '!' OR content LIKE ? ESCAPE '!' ORDER BY id DESC", pattern);
    }

    private List<Note> query(String sql, String pattern) {
        List<Note> notes = new ArrayList<>();
        try (Connection connection = connect(); PreparedStatement statement = connection.prepareStatement(sql)) {
            if (pattern != null) { statement.setString(1, pattern); statement.setString(2, pattern); }
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Note note = new Note(rs.getInt("id"), rs.getString("title"), rs.getString("content"), rs.getInt("type_id"));
                    note.setStrategy(this);
                    notes.add(note);
                }
            }
            return notes;
        } catch (SQLException e) { throw new StorageException("Không đọc được ghi chú từ MySQL.", e); }
    }

    @Override
    public List<NoteType> findTypes() {
        List<NoteType> types = new ArrayList<>();
        try (Connection connection = connect(); PreparedStatement statement = connection.prepareStatement("SELECT id, name, description FROM note_type ORDER BY id"); ResultSet rs = statement.executeQuery()) {
            while (rs.next()) types.add(new NoteType(rs.getInt("id"), rs.getString("name"), rs.getString("description")));
            return types;
        } catch (SQLException e) { throw new StorageException("Không đọc được phân loại từ MySQL.", e); }
    }
}
