package com.codegym.products.web;

import java.math.BigDecimal;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ProductFormTest {
    @Test void acceptsVietnameseAndPreservesDecimalMoney() {
        ProductForm form = new ProductForm(7, "  Bàn phím cơ  ", " 1250.10 ", "12");
        assertTrue(form.validate().isEmpty());
        assertEquals(7, form.toProduct().getId());
        assertEquals("Bàn phím cơ", form.toProduct().getName());
        assertEquals(new BigDecimal("1250.10"), form.toProduct().getPrice());
    }

    @Test void acceptsZeroAndMaximumStorageValues() {
        assertTrue(new ProductForm(0, "Hàng mẫu", "0", "0").validate().isEmpty());
        ProductForm max = new ProductForm(0, "A".repeat(255), "9999999999999.99", "2147483647");
        assertTrue(max.validate().isEmpty());
        assertEquals(new BigDecimal("9999999999999.99"), max.toProduct().getPrice());
    }

    @Test void rejectsBlankOrTooLongNames() {
        assertTrue(new ProductForm(0, " \t", "1", "1").validate().containsKey("name"));
        assertTrue(new ProductForm(0, "A".repeat(256), "1", "1").validate().containsKey("name"));
    }

    @Test void rejectsInvalidMoneyWithoutSilentlyRounding() {
        for (String value : new String[]{"", "-1", "1.001", "NaN", "1e3", "1,5", "10000000000000"})
            assertTrue(new ProductForm(0, "A", value, "1").validate().containsKey("price"), value);
    }

    @Test void rejectsInvalidQuantity() {
        for (String value : new String[]{"", "-1", "1.5", "abc", "2147483648", "999999999999"})
            assertTrue(new ProductForm(0, "A", "1", value).validate().containsKey("quantity"), value);
    }

    @Test void preservesSubmittedDataForErrorsAndRefusesConversion() {
        ProductForm form = new ProductForm(3, " Tên gốc ", "abc", "4");
        assertEquals(" Tên gốc ", form.getName());
        assertEquals("abc", form.getPrice());
        assertThrows(IllegalArgumentException.class, form::toProduct);
    }

    @Test void escapesUserInputInHtmlAndAttributes() {
        assertEquals("&lt;script&gt;&amp;&quot;&#39;", Html.escape("<script>&\"'"));
        assertEquals("", Html.escape(null));
    }
}
