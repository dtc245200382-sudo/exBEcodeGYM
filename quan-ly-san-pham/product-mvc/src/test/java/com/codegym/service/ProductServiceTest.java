package com.codegym.service;

import com.codegym.controller.ProductForm;
import com.codegym.model.Product;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ProductServiceTest {
    private final ProductService service = new ProductServiceImpl();

    private Product draft(String name) {
        return new Product(0, name, new BigDecimal("123.45"), "Mô tả", "Nhà sản xuất");
    }

    @Test void createsReadsUpdatesAndDeletes() {
        Product saved = service.save(draft("Sản phẩm kiểm thử"));
        try {
            assertTrue(saved.getId() > 0);
            assertEquals("Sản phẩm kiểm thử", service.findById(saved.getId()).getName());
            Product changed = new Product(saved.getId(), "Đã sửa", new BigDecimal("99.10"), "Mô tả mới", "Hãng mới");
            assertTrue(service.update(saved.getId(), changed));
            assertEquals(new BigDecimal("99.10"), service.findById(saved.getId()).getPrice());
            assertTrue(service.remove(saved.getId()));
            assertNull(service.findById(saved.getId()));
        } finally { service.remove(saved.getId()); }
    }

    @Test void dataIsSharedBetweenServiceInstances() {
        Product saved = service.save(draft("Dùng chung"));
        try { assertEquals("Dùng chung", new ProductServiceImpl().findById(saved.getId()).getName()); }
        finally { service.remove(saved.getId()); }
    }

    @Test void searchesPartialNamesIgnoringCaseAndSpaces() {
        assertEquals(2, service.searchByName("  BÀN PHÍM ").size());
        assertTrue(service.searchByName("kết nối USB").isEmpty());
        assertEquals(service.findAll().size(), service.searchByName(" \t ").size());
        assertEquals(service.findAll().size(), service.searchByName(null).size());
    }

    @Test void idsAreNotReusedAndExistingProductsCannotBeOverwrittenBySave() {
        Product first = service.save(draft("First"));
        service.remove(first.getId());
        Product second = service.save(draft("Second"));
        try {
            assertTrue(second.getId() > first.getId());
            assertThrows(IllegalArgumentException.class, () -> service.save(second));
            assertEquals("Second", service.findById(second.getId()).getName());
        } finally { service.remove(second.getId()); }
    }

    @Test void listIsASnapshotAndCannotRemoveStoredProducts() {
        List<Product> snapshot = service.findAll();
        int count = snapshot.size();
        snapshot.clear();
        assertEquals(count, service.findAll().size());
    }

    @Test void concurrentCreatesHaveUniqueIds() throws Exception {
        var executor = Executors.newFixedThreadPool(8);
        List<Future<Product>> futures = new ArrayList<>();
        List<Product> saved = new ArrayList<>();
        try {
            for (int i = 0; i < 40; i++) futures.add(executor.submit(() -> service.save(draft("Concurrent"))));
            for (Future<Product> future : futures) saved.add(future.get());
            assertEquals(40, new HashSet<>(saved.stream().map(Product::getId).toList()).size());
        } finally {
            executor.shutdown();
            executor.awaitTermination(5, java.util.concurrent.TimeUnit.SECONDS);
            for (Future<Product> future : futures) if (future.isDone() && !future.isCancelled()) {
                service.remove(future.get().getId());
            }
        }
    }

    @Test void staleUpdateDoesNotRecreateDeletedProduct() {
        Product saved = service.save(draft("Stale"));
        service.remove(saved.getId());
        assertFalse(service.update(saved.getId(), saved));
        assertNull(service.findById(saved.getId()));
        assertFalse(service.remove(saved.getId()));
    }

    @Test void validatesMoneyWithoutRounding() {
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", new BigDecimal("-1"), "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", new BigDecimal("1.001"), "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", new BigDecimal("10000000000000"), "", "B"));
        assertEquals(new BigDecimal("0.00"), new Product(0, "A", BigDecimal.ZERO, "", "B").getPrice());
    }

    @Test void validatesRequiredTextAndDescriptionLength() {
        assertThrows(IllegalArgumentException.class, () -> new Product(0, " ", BigDecimal.ONE, "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", BigDecimal.ONE, "", " "));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A".repeat(256), BigDecimal.ONE, "", "B"));
        assertThrows(IllegalArgumentException.class, () -> new Product(0, "A", BigDecimal.ONE, "x".repeat(2001), "B"));
    }

    @Test void formPreservesDraftAndParsesDecimalPrice() {
        ProductForm valid = new ProductForm(0, "  Bàn phím  ", " 99.10 ", "Mô tả", " KeyPro ");
        assertEquals("Bàn phím", valid.toProduct().getName());
        assertEquals(new BigDecimal("99.10"), valid.toProduct().getPrice());
        ProductForm invalid = new ProductForm(0, "Tên gốc", "1e3", "Nội dung gốc", "Hãng");
        assertEquals("Tên gốc", invalid.getName());
        assertEquals("Nội dung gốc", invalid.getDescription());
        assertThrows(IllegalArgumentException.class, invalid::toProduct);
    }
}
