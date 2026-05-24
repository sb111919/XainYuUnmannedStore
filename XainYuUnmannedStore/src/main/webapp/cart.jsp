<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shop.entity.CartItem, java.util.List" %>
<html>
<head>
    <title>購物車 - 購物網站</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; min-height: 100vh; padding: 32px 20px; background: linear-gradient(135deg, #f7fbf4 0%, #edf6f2 46%, #fff8ec 100%); color: #27332f; }
        .container { max-width: 920px; margin: 0 auto; background: rgba(255,255,255,0.94); padding: 24px; border-radius: 8px; box-shadow: 0 16px 40px rgba(46, 75, 60, 0.14); border: 1px solid rgba(80, 125, 95, 0.16); }
        h2 { text-align: center; color: #27332f; margin-top: 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; background: white; border-radius: 8px; overflow: hidden; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #eef6ef; color: #2f4a38; }
        .total { text-align: right; font-size: 1.25rem; font-weight: bold; margin-top: 20px; color: #c45123; }
        .actions { display: flex; justify-content: space-between; margin-top: 20px; }
        .btn { padding: 10px 20px; text-decoration: none; border-radius: 4px; color: white; border: none; cursor: pointer; font-size: 1rem; }
        .btn-primary { background-color: #2f7d57; }
        .btn-checkout { background-color: #c45123; }
        .btn-danger { background-color: #dc3545; }
        .btn:hover { opacity: 0.9; }
        .notice { margin: 0 0 16px; padding: 12px 14px; border-radius: 6px; font-weight: bold; }
        .notice-success { background: #e6f6ea; color: #21633a; border: 1px solid #b9dfc4; }
        .notice-error { background: #fdebea; color: #9d2f25; border: 1px solid #f2b8b2; }
        @media (max-width: 720px) {
            .container { padding: 16px; }
            table { display: block; overflow-x: auto; }
            .actions { flex-direction: column; gap: 12px; }
            .btn { text-align: center; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>我的購物車</h2>
        <%
            String checkoutMessage = (String) session.getAttribute("checkoutMessage");
            Double checkoutTotal = (Double) session.getAttribute("checkoutTotal");
            String checkoutError = (String) session.getAttribute("checkoutError");
            if (checkoutMessage != null) {
        %>
            <div class="notice notice-success">
                <%= checkoutMessage %>
                <% if (checkoutTotal != null) { %>
                    本次付款金額：￥<%= String.format("%.2f", checkoutTotal) %>
                <% } %>
            </div>
        <%
                session.removeAttribute("checkoutMessage");
                session.removeAttribute("checkoutTotal");
            }
            if (checkoutError != null) {
        %>
            <div class="notice notice-error"><%= checkoutError %></div>
        <%
                session.removeAttribute("checkoutError");
            }
        %>
        <table>
            <thead>
                <tr>
                    <th>商品名稱</th>
                    <th>單價</th>
                    <th>數量</th>
                    <th>小計</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
                    double total = 0;
                    if (cart != null && !cart.isEmpty()) {
                        for (CartItem item : cart) {
                            total += item.getSubtotal();
                %>
                    <tr>
                        <td><%= item.getProduct().getName() %></td>
                        <td>￥<%= item.getProduct().getPrice() %></td>
                        <td><%= item.getQuantity() %></td>
                        <td>￥<%= String.format("%.2f", item.getSubtotal()) %></td>
                        <td>
                            <form action="cart" method="post" style="margin:0;">
                                <input type="hidden" name="action" value="remove">
                                <input type="hidden" name="productId" value="<%= item.getProduct().getId() %>">
                                <button type="submit" class="btn btn-danger" style="padding: 5px 10px;">刪除</button>
                            </form>
                        </td>
                    </tr>
                <% 
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="5" style="text-align:center;">購物車是空的</td>
                    </tr>
                <% } %>
            </tbody>
        </table>

        <div class="total">總計: ￥<%= String.format("%.2f", total) %></div>

        <div class="actions">
            <a href="products" class="btn btn-primary">繼續購物</a>
            <a href="orders" class="btn btn-primary">歷史訂單</a>
            <% if (cart != null && !cart.isEmpty()) { %>
                <form action="cart" method="post" style="margin:0;">
                    <input type="hidden" name="action" value="checkout">
                    <button type="submit" class="btn btn-checkout">去結帳</button>
                </form>
            <% } %>
        </div>
    </div>
</body>
</html>
