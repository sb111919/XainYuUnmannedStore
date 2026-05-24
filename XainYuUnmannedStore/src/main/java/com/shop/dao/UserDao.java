package com.shop.dao;

import com.shop.entity.User;
import java.sql.SQLException;

public interface UserDao {
    User findByUsername(String username) throws SQLException;
    int save(User user) throws SQLException;
    int update(User user) throws SQLException;
    int delete(Integer id) throws SQLException;
    User findById(Integer id) throws SQLException;
}
