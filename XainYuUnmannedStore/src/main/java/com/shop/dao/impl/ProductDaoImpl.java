package com.shop.dao.impl;

import com.shop.dao.ProductDao;
import com.shop.entity.Product;
import com.shop.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDaoImpl implements ProductDao {

    @Override
    public List<Product> findAll() throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY category, id";
        try (Connection conn = DBUtil.getConnection()) {
            ensureCategoryColumn(conn);
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {
                while (rs.next()) {
                    products.add(mapResultSetToProduct(rs));
                }
            }
        }
        return products;
    }

    @Override
    public List<Product> findByCategory(String category) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category = ? ORDER BY id";
        try (Connection conn = DBUtil.getConnection()) {
            ensureCategoryColumn(conn);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, category);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        products.add(mapResultSetToProduct(rs));
                    }
                }
            }
        }
        return products;
    }

    @Override
    public List<String> findCategories() throws SQLException {
        List<String> categories = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category <> '' ORDER BY category";
        try (Connection conn = DBUtil.getConnection()) {
            ensureCategoryColumn(conn);
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {
                while (rs.next()) {
                    categories.add(rs.getString("category"));
                }
            }
        }
        return categories;
    }

    @Override
    public Product findById(Integer id) throws SQLException {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            ensureCategoryColumn(conn);
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, id);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        return mapResultSetToProduct(rs);
                    }
                }
            }
        }
        return null;
    }

    private void ensureCategoryColumn(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            if (!hasCategoryColumn(conn)) {
                stmt.executeUpdate("ALTER TABLE products ADD COLUMN category VARCHAR(50) NOT NULL DEFAULT '其他' AFTER name");
            }
            stmt.executeUpdate("UPDATE products SET category = '書籍' WHERE id IN (SELECT id FROM (SELECT id FROM products WHERE name IN ('Java 編程思想', 'Spring Boot 實戰', 'MySQL 從入門到精通')) matched_products)");
            stmt.executeUpdate("UPDATE products SET category = '生鮮' WHERE id IN (SELECT id FROM (SELECT id FROM products WHERE name IN ('生鮮高山高麗菜', '生鮮台灣香蕉', '生鮮雞胸肉', '生鮮鮭魚切片')) matched_products)");
            stmt.executeUpdate("UPDATE products SET category = '零食' WHERE id IN (SELECT id FROM (SELECT id FROM products WHERE name IN ('零食洋芋片', '零食巧克力餅乾', '零食綜合堅果', '零食水果軟糖')) matched_products)");
            stmt.executeUpdate("UPDATE products SET category = '家電' WHERE id IN (SELECT id FROM (SELECT id FROM products WHERE name IN ('家電電熱水壺', '家電微波爐', '家電空氣清淨機', '家電無線吸塵器')) matched_products)");
        }
    }

    private boolean hasCategoryColumn(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT category FROM products LIMIT 1")) {
            return true;
        } catch (SQLException e) {
            if (e.getErrorCode() == 1054) {
                return false;
            }
            throw e;
        }
    }

    private Product mapResultSetToProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setId(rs.getInt("id"));
        product.setName(rs.getString("name"));
        product.setCategory(rs.getString("category"));
        product.setPrice(rs.getBigDecimal("price"));
        product.setDescription(rs.getString("description"));
        product.setStock(rs.getInt("stock"));
        return product;
    }
}
