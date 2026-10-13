package com.codegym.inotes.storage;

import com.codegym.inotes.model.Note;
import com.codegym.inotes.model.NoteType;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.nio.channels.FileLock;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.text.Normalizer;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.locks.ReentrantLock;

public class NoteFileStrategy implements NoteStrategy {
    private static final Map<Path, ReentrantLock> LOCKS = new ConcurrentHashMap<>();
    private static final List<NoteType> TYPES = List.of(
            new NoteType(1, "Cá nhân", "Ghi chú cá nhân"),
            new NoteType(2, "Công việc", "Công việc cần ghi nhớ"),
            new NoteType(3, "Học tập", "Nội dung học tập"));
    private final Path directory;

    public NoteFileStrategy(Path directory) { this.directory = directory.toAbsolutePath().normalize(); }
    @Override public String name() { return "file"; }
    @Override public List<NoteType> findTypes() { return TYPES; }

    @FunctionalInterface private interface Operation<T> { T run() throws IOException; }
    private <T> T locked(Operation<T> operation) {
        ReentrantLock lock = LOCKS.computeIfAbsent(directory, key -> new ReentrantLock());
        lock.lock();
        try {
            Files.createDirectories(directory);
            try (FileChannel channel = FileChannel.open(directory.resolve("notes.lock"), StandardOpenOption.CREATE, StandardOpenOption.WRITE);
                 FileLock ignored = channel.lock()) {
                return operation.run();
            }
        } catch (IOException e) { throw new StorageException("Không đọc/ghi được file ghi chú.", e); }
        finally { lock.unlock(); }
    }

    @Override
    public void save(Note note) {
        note.validate();
        if (TYPES.stream().noneMatch(type -> type.id() == note.getTypeId()))
            throw new IllegalArgumentException("Phân loại không tồn tại.");
        locked(() -> {
            List<Note> notes = readNotes();
            if (note.getId() == 0) {
                int max = notes.stream().mapToInt(Note::getId).max().orElse(0);
                Path sequencePath = directory.resolve("next-id.txt");
                int next = Math.addExact(max, 1);
                if (Files.exists(sequencePath)) {
                    try { next = Math.max(next, Integer.parseInt(Files.readString(sequencePath).strip())); }
                    catch (NumberFormatException e) { throw new IOException("Invalid ID sequence", e); }
                }
                if (next <= 0) throw new IOException("Invalid ID sequence");
                // Giữ high-water mark trước khi lưu; lỗi ghi có thể tạo khoảng trống ID, không tái sử dụng ID.
                atomicWrite(sequencePath, Integer.toString(Math.addExact(next, 1)));
                Note stored = new Note(next, note.getTitle(), note.getContent(), note.getTypeId());
                notes.add(stored);
                writeNotes(notes);
                note.setId(next);
            } else {
                int position = -1;
                for (int i = 0; i < notes.size(); i++) if (notes.get(i).getId() == note.getId()) { position = i; break; }
                if (position < 0) throw new IllegalArgumentException("Không tìm thấy ghi chú cần sửa.");
                notes.set(position, new Note(note.getId(), note.getTitle(), note.getContent(), note.getTypeId()));
                writeNotes(notes);
            }
            return null;
        });
    }

    @Override
    public void delete(int id) {
        if (id <= 0) throw new IllegalArgumentException("ID không hợp lệ.");
        locked(() -> {
            List<Note> notes = readNotes();
            if (!notes.removeIf(note -> note.getId() == id)) throw new IllegalArgumentException("Không tìm thấy ghi chú cần xoá.");
            writeNotes(notes);
            return null;
        });
    }

    @Override
    public List<Note> findAll() {
        return locked(() -> readNotes().stream().sorted(Comparator.comparingInt(Note::getId).reversed()).toList());
    }

    private static String folded(String value) {
        return Normalizer.normalize(value == null ? "" : value.toLowerCase(Locale.ROOT), Normalizer.Form.NFD)
                .replaceAll("\\p{M}", "").replace('đ', 'd');
    }

    @Override
    public List<Note> search(String keyword) {
        String query = folded(keyword == null ? "" : keyword.strip());
        return findAll().stream().filter(note -> folded(note.getTitle()).contains(query) || folded(note.getContent()).contains(query)).toList();
    }

    private List<Note> readNotes() throws IOException {
        Path path = directory.resolve("notes.txt");
        List<Note> notes = new ArrayList<>();
        if (!Files.exists(path)) return notes;
        Set<Integer> ids = new HashSet<>();
        int lineNumber = 0;
        for (String line : Files.readAllLines(path, StandardCharsets.UTF_8)) {
            lineNumber++;
            if (line.isEmpty()) continue;
            List<String> fields = decode(line);
            try {
                if (fields.size() != 4) throw new IllegalArgumentException("Expected four fields");
                Note note = new Note(Integer.parseInt(fields.get(0)), fields.get(1), fields.get(2), Integer.parseInt(fields.get(3)));
                note.validate();
                if (note.getId() <= 0 || !ids.add(note.getId()) || TYPES.stream().noneMatch(type -> type.id() == note.getTypeId()))
                    throw new IllegalArgumentException("Invalid record");
                note.setStrategy(this);
                notes.add(note);
            } catch (IllegalArgumentException e) { throw new IOException("Invalid note at line " + lineNumber, e); }
        }
        return notes;
    }

    private static String encode(String value) {
        return value.replace("\\", "\\\\").replace("|", "\\|").replace("\n", "\\n").replace("\r", "\\r");
    }

    private static List<String> decode(String line) throws IOException {
        List<String> fields = new ArrayList<>();
        StringBuilder field = new StringBuilder();
        boolean escaped = false;
        for (char character : line.toCharArray()) {
            if (escaped) {
                switch (character) {
                    case 'n' -> field.append('\n');
                    case 'r' -> field.append('\r');
                    case '\\', '|' -> field.append(character);
                    default -> throw new IOException("Invalid escape sequence in notes file");
                }
                escaped = false;
            } else if (character == '\\') escaped = true;
            else if (character == '|') { fields.add(field.toString()); field.setLength(0); }
            else field.append(character);
        }
        if (escaped) throw new IOException("Incomplete escape sequence in notes file");
        fields.add(field.toString());
        return fields;
    }

    private void writeNotes(List<Note> notes) throws IOException {
        StringBuilder text = new StringBuilder();
        for (Note note : notes) text.append(note.getId()).append('|').append(encode(note.getTitle())).append('|')
                .append(encode(note.getContent())).append('|').append(note.getTypeId()).append('\n');
        atomicWrite(directory.resolve("notes.txt"), text.toString());
    }

    private void atomicWrite(Path destination, String content) throws IOException {
        Path temporary = Files.createTempFile(directory, "inotes-", ".tmp");
        try {
            Files.writeString(temporary, content, StandardCharsets.UTF_8);
            try { Files.move(temporary, destination, StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING); }
            catch (AtomicMoveNotSupportedException e) { Files.move(temporary, destination, StandardCopyOption.REPLACE_EXISTING); }
        } finally { Files.deleteIfExists(temporary); }
    }
}
