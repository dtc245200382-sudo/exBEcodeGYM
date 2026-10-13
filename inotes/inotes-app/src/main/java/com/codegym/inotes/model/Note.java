package com.codegym.inotes.model;

import com.codegym.inotes.storage.NoteStrategy;

public class Note {
    private int id;
    private String title;
    private String content;
    private int typeId;
    private transient NoteStrategy strategy;

    public Note() { }

    public Note(int id, String title, String content, int typeId) {
        this.id = id;
        this.title = title;
        this.content = content;
        this.typeId = typeId;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public int getTypeId() { return typeId; }
    public void setTypeId(int typeId) { this.typeId = typeId; }
    public void setStrategy(NoteStrategy strategy) { this.strategy = strategy; }

    public void validate() {
        if (id < 0) throw new IllegalArgumentException("ID không hợp lệ.");
        if (title == null || title.isBlank()) throw new IllegalArgumentException("Vui lòng nhập tiêu đề.");
        title = title.strip();
        if (title.length() > 255) throw new IllegalArgumentException("Tiêu đề tối đa 255 ký tự.");
        if (content == null) content = "";
        if (content.length() > 10000) throw new IllegalArgumentException("Nội dung tối đa 10.000 ký tự.");
        if (typeId <= 0) throw new IllegalArgumentException("Vui lòng chọn phân loại.");
    }

    public void save() {
        if (strategy == null) throw new IllegalStateException("Chưa chọn chiến lược lưu trữ.");
        strategy.save(this);
    }

    public void delete(int id) {
        if (strategy == null) throw new IllegalStateException("Chưa chọn chiến lược lưu trữ.");
        strategy.delete(id);
    }
}
