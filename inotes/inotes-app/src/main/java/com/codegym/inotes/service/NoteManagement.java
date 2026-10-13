package com.codegym.inotes.service;

import com.codegym.inotes.model.Note;
import com.codegym.inotes.model.NoteType;
import com.codegym.inotes.storage.NoteStrategy;
import java.util.List;
import java.util.Objects;

public class NoteManagement {
    private NoteStrategy strategy;

    public NoteManagement(NoteStrategy strategy) { setStrategy(strategy); }
    public void setStrategy(NoteStrategy strategy) { this.strategy = Objects.requireNonNull(strategy); }
    public String storageName() { return strategy.name(); }
    public List<NoteType> findTypes() { return strategy.findTypes(); }
    public List<Note> findAll() { return strategy.findAll(); }
    public List<Note> searchNotes(String keyword) { return strategy.search(keyword); }

    public Note findById(int id) {
        return strategy.findAll().stream().filter(note -> note.getId() == id).findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy ghi chú."));
    }

    public Note addNote(String title, String content, int typeId) {
        return saveNote(0, title, content, typeId);
    }

    public Note saveNote(int id, String title, String content, int typeId) {
        Note note = new Note(id, title, content, typeId);
        note.setStrategy(strategy);
        note.save();
        return note;
    }

    public void deleteNote(int id) {
        Note note = new Note();
        note.setStrategy(strategy);
        note.delete(id);
    }
}
