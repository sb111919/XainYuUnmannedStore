package com.shop.controller;

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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/orders")
public class OrderHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            req.setAttribute("orders", findUserOrders(conn, user.getId()));
            req.getRequestDispatcher("/order-history.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private List<String[]> findUserOrders(Connection conn, int userId) throws SQLException {
        List<String[]> orders = new ArrayList<>();
        String sql = """
                SELECT o.id, o.total, o.created_at,
                       GROUP_CONCAT(CONCAT(oi.product_name, ' x ', oi.quantity, ' = ￥', oi.subtotal)
                                    ORDER BY oi.id SEPARATOR '<br>') AS items
                FROM orders o
                LEFT JOIN order_items oi ON o.id = oi.order_id
                WHERE o.user_id = ?
                GROUP BY o.id, o.total, o.created_at
                ORDER BY o.created_at DESC, o.id DESC
                """;
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    orders.add(new String[] {
                            String.valueOf(rs.getInt("id")),
                            rs.getBigDecimal("total").toString(),
                            rs.getTimestamp("created_at").toString(),
                            rs.getString("items") == null ? "" : rs.getString("items")
                    });
                }
            }
        }
        return orders;
    }
}
