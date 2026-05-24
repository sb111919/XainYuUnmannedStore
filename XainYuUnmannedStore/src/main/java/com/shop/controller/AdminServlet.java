package com.shop.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.shop.entity.Product;
import com.shop.entity.User;
import com.shop.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            String productKeyword = trim(req.getParameter("productKeyword"));
            String orderKeyword = trim(req.getParameter("orderKeyword"));
            req.setAttribute("products", findProducts(conn, productKeyword));
            req.setAttribute("users", findUsers(conn));
            req.setAttribute("totalProducts", count(conn, "products"));
            req.setAttribute("totalUsers", count(conn, "users"));
            req.setAttribute("totalStock", sumStock(conn));
            req.setAttribute("totalOrders", count(conn, "orders"));
            req.setAttribute("totalSales", sumSales(conn));
            req.setAttribute("categoryStats", findCategoryStats(conn));
            req.setAttribute("orders", findOrders(conn, orderKeyword));
            req.setAttribute("productKeyword", productKeyword);
            req.setAttribute("orderKeyword", orderKeyword);
            req.getRequestDispatcher("/admin.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!isAdmin(req)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        try (Connection conn = DBUtil.getConnection()) {
            if ("updateProduct".equals(action)) {
                updateProduct(req, conn);
                req.getSession().setAttribute("adminMessage", "商品已更新。");
            } else if ("deleteProduct".equals(action)) {
                deleteProduct(req, conn);
                req.getSession().setAttribute("adminMessage", "商品已刪除。");
            }
        } catch (SQLException | NumberFormatException e) {
            e.printStackTrace();
            req.getSession().setAttribute("adminError", "操作失敗，請確認輸入內容。");
        }
        resp.sendRedirect(req.getContextPath() + "/admin");
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return false;
        }
        User user = (User) session.getAttribute("user");
        return user != null && "admin".equals(user.getRole());
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private List<Product> findProducts(Connection conn, String keyword) throws SQLException {
        List<Product> products = new ArrayList<>();
        String sql = """
                SELECT *
                FROM products
                WHERE ? = ''
                   OR name LIKE ?
                   OR category LIKE ?
                   OR description LIKE ?
                ORDER BY category, name, id
                """;
        String likeKeyword = "%" + keyword + "%";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, keyword);
            pstmt.setString(2, likeKeyword);
            pstmt.setString(3, likeKeyword);
            pstmt.setString(4, likeKeyword);
            try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Product product = new Product();
                product.setId(rs.getInt("id"));
                product.setName(rs.getString("name"));
                product.setCategory(rs.getString("category"));
                product.setPrice(rs.getBigDecimal("price"));
                product.setDescription(rs.getString("description"));
                product.setStock(rs.getInt("stock"));
                products.add(product);
            }
            }
        }
        return products;
    }

    private List<User> findUsers(Connection conn) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY id";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                users.add(user);
            }
        }
        return users;
    }

    private List<String[]> findCategoryStats(Connection conn) throws SQLException {
        List<String[]> stats = new ArrayList<>();
        String sql = "SELECT category, COUNT(*) product_count, COALESCE(SUM(stock), 0) stock_count FROM products GROUP BY category ORDER BY category";
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                stats.add(new String[] {
                        rs.getString("category"),
                        String.valueOf(rs.getInt("product_count")),
                        String.valueOf(rs.getInt("stock_count"))
                });
            }
        }
        return stats;
    }

    private List<String[]> findOrders(Connection conn, String keyword) throws SQLException {
        List<String[]> orders = new ArrayList<>();
        String sql = """
                SELECT o.id, o.customer_name, o.customer_email, o.total, o.created_at,
                       GROUP_CONCAT(CONCAT(oi.product_name, ' x ', oi.quantity, ' = ￥', oi.subtotal)
                                    ORDER BY oi.id SEPARATOR '<br>') AS items
                FROM orders o
                LEFT JOIN order_items oi ON o.id = oi.order_id
                WHERE ? = ''
                   OR CAST(o.id AS CHAR) LIKE ?
                   OR o.customer_name LIKE ?
                   OR o.customer_email LIKE ?
                   OR EXISTS (
                       SELECT 1
                       FROM order_items matched_item
                       WHERE matched_item.order_id = o.id
                         AND matched_item.product_name LIKE ?
                   )
                GROUP BY o.id, o.customer_name, o.customer_email, o.total, o.created_at
                ORDER BY o.created_at DESC, o.id DESC
                """;
        String likeKeyword = "%" + keyword + "%";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, keyword);
            pstmt.setString(2, likeKeyword);
            pstmt.setString(3, likeKeyword);
            pstmt.setString(4, likeKeyword);
            pstmt.setString(5, likeKeyword);
            try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                orders.add(new String[] {
                        String.valueOf(rs.getInt("id")),
                        rs.getString("customer_name"),
                        rs.getString("customer_email"),
                        rs.getBigDecimal("total").toString(),
                        rs.getTimestamp("created_at").toString(),
                        rs.getString("items") == null ? "" : rs.getString("items")
                });
            }
            }
        }
        return orders;
    }

    private int count(Connection conn, String table) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM " + table)) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private int sumStock(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COALESCE(SUM(stock), 0) FROM products")) {
            rs.next();
            return rs.getInt(1);
        }
    }

    private BigDecimal sumSales(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT COALESCE(SUM(total), 0) FROM orders")) {
            rs.next();
            return rs.getBigDecimal(1);
        }
    }

    private void updateProduct(HttpServletRequest req, Connection conn) throws SQLException {
        String sql = "UPDATE products SET category = ?, price = ?, stock = ? WHERE id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, req.getParameter("category"));
            pstmt.setBigDecimal(2, new BigDecimal(req.getParameter("price")));
            pstmt.setInt(3, Integer.parseInt(req.getParameter("stock")));
            pstmt.setInt(4, Integer.parseInt(req.getParameter("productId")));
            pstmt.executeUpdate();
        }
    }

    private void deleteProduct(HttpServletRequest req, Connection conn) throws SQLException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        try (PreparedStatement deleteCartItems = conn.prepareStatement("DELETE FROM cart_items WHERE product_id = ?")) {
            deleteCartItems.setInt(1, productId);
            deleteCartItems.executeUpdate();
        }
        try (PreparedStatement unlinkOrderItems = conn.prepareStatement("UPDATE order_items SET product_id = NULL WHERE product_id = ?")) {
            unlinkOrderItems.setInt(1, productId);
            unlinkOrderItems.executeUpdate();
        }
        try (PreparedStatement deleteProduct = conn.prepareStatement("DELETE FROM products WHERE id = ?")) {
            deleteProduct.setInt(1, productId);
            deleteProduct.executeUpdate();
        }
    }
}
