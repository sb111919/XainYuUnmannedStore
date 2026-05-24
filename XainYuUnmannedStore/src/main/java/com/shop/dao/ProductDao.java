package com.shop.dao;

import com.shop.entity.Product;
import java.sql.SQLException;
import java.util.List;

public interface ProductDao {
    List<Product> findAll() throws SQLException;
    List<Product> findByCategory(String category) throws SQLException;
    List<String> findCategories() throws SQLException;
    Product findById(Integer id) throws SQLException;
}
