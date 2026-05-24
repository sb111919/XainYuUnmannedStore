package com.shop.controller;

import com.shop.dao.ProductDao;
import com.shop.dao.impl.ProductDaoImpl;
import com.shop.entity.CartItem;
import com.shop.entity.Product;
import com.shop.entity.User;
import com.shop.util.DBUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/cart")
public class CartServlet extends HttpServlet {
    private ProductDao productDao = new ProductDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/cart.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("add".equals(action)) {
            addToCart(req, resp);
        } else if ("remove".equals(action)) {
            removeFromCart(req, resp);
        } else if ("checkout".equals(action)) {
            checkout(req, resp);
        }
    }

    private void addToCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));

        HttpSession session = req.getSession();
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        try {
            Product product = productDao.findById(productId);
            if (product != null) {
                boolean found = false;
                for (CartItem item : cart) {
                    if (item.getProduct().getId().equals(productId)) {
                        item.setQuantity(item.getQuantity() + quantity);
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    cart.add(new CartItem(product, quantity));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void removeFromCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int productId = Integer.parseInt(req.getParameter("productId"));
        HttpSession session = req.getSession();
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart != null) {
            cart.removeIf(item -> item.getProduct().getId().equals(productId));
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private void checkout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            session.setAttribute("checkoutError", "購物車是空的，請先加入商品。");
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                BigDecimal total = BigDecimal.ZERO;
                for (CartItem item : cart) {
                    int productId = item.getProduct().getId();
                    int quantity = item.getQuantity();

                    try (PreparedStatement checkStmt = conn.prepareStatement(
                            "SELECT name, price, stock FROM products WHERE id = ? FOR UPDATE")) {
                        checkStmt.setInt(1, productId);
                        try (ResultSet rs = checkStmt.executeQuery()) {
                            if (!rs.next()) {
                                throw new IllegalStateException("商品不存在：" + item.getProduct().getName());
                            }
                            int stock = rs.getInt("stock");
                            if (stock < quantity) {
                                throw new IllegalStateException(rs.getString("name") + "庫存不足，目前剩餘 " + stock + " 件。");
                            }
                            total = total.add(rs.getBigDecimal("price").multiply(BigDecimal.valueOf(quantity)));
                        }
                    }

                    try (PreparedStatement updateStmt = conn.prepareStatement(
                            "UPDATE products SET stock = stock - ? WHERE id = ?")) {
                        updateStmt.setInt(1, quantity);
                        updateStmt.setInt(2, productId);
                        updateStmt.executeUpdate();
                    }
                }

                int orderId = createOrder(conn, session, total);
                createOrderItems(conn, orderId, cart);
                conn.commit();
                session.removeAttribute("cart");
                session.setAttribute("checkoutMessage", "結帳成功！感謝您的購買。");
                session.setAttribute("checkoutTotal", total.doubleValue());
            } catch (Exception e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackException) {
                    rollbackException.printStackTrace();
                }
                session.setAttribute("checkoutError", e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("checkoutError", "結帳失敗，請稍後再試。");
        }
        resp.sendRedirect(req.getContextPath() + "/cart");
    }

    private int createOrder(Connection conn, HttpSession session, BigDecimal total) throws SQLException {
        User user = (User) session.getAttribute("user");
        Integer userId = user == null ? null : user.getId();
        String customerName = user == null ? "訪客" : user.getUsername();
        String customerEmail = user == null ? "" : user.getEmail();

        String sql = "INSERT INTO orders (user_id, customer_name, customer_email, total) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (userId == null) {
                pstmt.setNull(1, java.sql.Types.INTEGER);
            } else {
                pstmt.setInt(1, userId);
            }
            pstmt.setString(2, customerName);
            pstmt.setString(3, customerEmail);
            pstmt.setBigDecimal(4, total);
            pstmt.executeUpdate();
            try (ResultSet keys = pstmt.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("建立訂單失敗");
    }

    private void createOrderItems(Connection conn, int orderId, List<CartItem> cart) throws SQLException {
        String sql = "INSERT INTO order_items (order_id, product_id, product_name, price, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            for (CartItem item : cart) {
                BigDecimal price = item.getProduct().getPrice();
                BigDecimal subtotal = price.multiply(BigDecimal.valueOf(item.getQuantity()));
                pstmt.setInt(1, orderId);
                pstmt.setInt(2, item.getProduct().getId());
                pstmt.setString(3, item.getProduct().getName());
                pstmt.setBigDecimal(4, price);
                pstmt.setInt(5, item.getQuantity());
                pstmt.setBigDecimal(6, subtotal);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
        }
    }
}
