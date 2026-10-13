package com.codegym.inotes;

import com.codegym.inotes.model.Note;
import com.codegym.inotes.service.NoteManagement;
import com.codegym.inotes.storage.NoteFileStrategy;
import com.codegym.inotes.storage.StorageException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.*;
import static org.junit.jupiter.api.Assertions.*;

class NoteFileStrategyTest {
    @TempDir Path directory;

    @Test void preservesUnicodeDelimitersAndMultilineContentAcrossReopen() {
        NoteFileStrategy strategy = new NoteFileStrategy(directory);
        Note note = new Note(0, "Học tập | Java \\ JSP", "Dòng 1 | nội dung\nDòng 2\\n\r\nDòng 3", 3);
        note.setStrategy(strategy);
        note.save();
        Note reopened = new NoteFileStrategy(directory).findAll().get(0);
        assertEquals(note.getTitle(), reopened.getTitle());
        assertEquals(note.getContent(), reopened.getContent());
        assertEquals(note.getId(), reopened.getId());
        assertEquals(3, reopened.getTypeId());
    }

    @Test void updatesAndDeletesUsingNoteModelWithoutReusingDeletedId() {
        NoteManagement management = new NoteManagement(new NoteFileStrategy(directory));
        Note note = management.addNote("Ban đầu", "Nội dung", 1);
        Note editable = management.findById(note.getId());
        editable.setTitle("Đã sửa");
        editable.setContent("Nội dung mới");
        editable.setTypeId(2);
        editable.save();
        assertEquals("Đã sửa", management.findById(note.getId()).getTitle());
        assertEquals(2, management.findById(note.getId()).getTypeId());
        editable.delete(note.getId());
        assertTrue(management.findAll().isEmpty());
        Note next = management.addNote("Tiếp theo", "", 1);
        assertTrue(next.getId() > note.getId());
        assertThrows(IllegalArgumentException.class, () -> management.deleteNote(note.getId()));
    }

    @Test void searchesTitleAndContentAndTreatsWildcardCharactersLiterally() {
        NoteManagement management = new NoteManagement(new NoteFileStrategy(directory));
        management.addNote("HỌC TẬP 50%", "Chi tiết Servlet", 3);
        management.addNote("Mua sách", "Danh sách cần nhớ", 1);
        assertEquals(1, management.searchNotes("hoc tap").size());
        assertEquals(1, management.searchNotes("servlet").size());
        assertEquals(1, management.searchNotes("%").size());
        assertEquals(0, management.searchNotes("_").size());
        assertEquals(2, management.searchNotes(null).size());
    }

    @Test void rejectsInvalidNotesBeforeWriting() {
        NoteManagement management = new NoteManagement(new NoteFileStrategy(directory));
        assertThrows(IllegalArgumentException.class, () -> management.addNote("   ", "text", 1));
        assertThrows(IllegalArgumentException.class, () -> management.addNote("x".repeat(256), "", 1));
        assertThrows(IllegalArgumentException.class, () -> management.addNote("Title", "", 999));
        assertThrows(IllegalArgumentException.class, () -> management.addNote("Title", "x".repeat(10001), 1));
        assertTrue(management.findAll().isEmpty());
    }

    @Test void switchesStorageAtRuntimeWithoutChangingBusinessMethods() {
        NoteFileStrategy first = new NoteFileStrategy(directory.resolve("first"));
        NoteFileStrategy second = new NoteFileStrategy(directory.resolve("second"));
        NoteManagement management = new NoteManagement(first);
        management.addNote("Kho A", "", 1);
        management.setStrategy(second);
        assertTrue(management.findAll().isEmpty());
        management.addNote("Kho B", "", 2);
        management.setStrategy(first);
        assertEquals("Kho A", management.findAll().get(0).getTitle());
        assertEquals("Kho B", second.findAll().get(0).getTitle());
    }

    @Test void doesNotOverwriteMalformedData() throws Exception {
        Files.writeString(directory.resolve("notes.txt"), "1|broken\n");
        String before = Files.readString(directory.resolve("notes.txt"));
        NoteManagement management = new NoteManagement(new NoteFileStrategy(directory));
        assertThrows(StorageException.class, () -> management.addNote("New", "", 1));
        assertEquals(before, Files.readString(directory.resolve("notes.txt")));
    }

    @Test void concurrentStrategiesDoNotLoseRecordsOrDuplicateIds() throws Exception {
        ExecutorService executor = Executors.newFixedThreadPool(4);
        try {
            List<Callable<Integer>> tasks = new ArrayList<>();
            for (int i = 0; i < 24; i++) {
                final int number = i;
                tasks.add(() -> new NoteManagement(new NoteFileStrategy(directory)).addNote("Ghi chú " + number, "Nội dung", 1).getId());
            }
            Set<Integer> ids = new HashSet<>();
            for (Future<Integer> future : executor.invokeAll(tasks)) ids.add(future.get());
            assertEquals(24, ids.size());
            assertEquals(24, new NoteFileStrategy(directory).findAll().size());
        } finally { executor.shutdownNow(); }
    }
}
