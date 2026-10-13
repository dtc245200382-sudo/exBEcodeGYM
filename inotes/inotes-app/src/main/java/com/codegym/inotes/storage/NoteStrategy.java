package com.codegym.inotes.storage;

import com.codegym.inotes.model.Note;
import com.codegym.inotes.model.NoteType;
import java.util.List;

public interface NoteStrategy {
    void save(Note note);
    void delete(int id);
    List<Note> findAll();
    List<Note> search(String keyword);
    List<NoteType> findTypes();
    String name();
}
