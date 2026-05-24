<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<html>
<head>
    <title>歷史訂單 - 購物網站</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; min-height: 100vh; padding: 32px 20px; background: linear-gradient(135deg, #f7fbf4 0%, #edf6f2 46%, #fff8ec 100%); color: #27332f; }
        .container { max-width: 980px; margin: 0 auto; background: rgba(255,255,255,0.94); padding: 24px; border-radius: 8px; box-shadow: 0 16px 40px rgba(46, 75, 60, 0.14); border: 1px solid rgba(80, 125, 95, 0.16); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        h2 { color: #27332f; margin: 0; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; vertical-align: top; }
        th { background-color: #eef6ef; color: #2f4a38; }
        .total { color: #c45123; font-weight: bold; }
        .empty { padding: 32px; text-align: center; color: #66746c; background: white; border-radius: 8px; }
        .btn { padding: 10px 20px; text-decoration: none; border-radius: 4px; color: white; background-color: #2f7d57; }
        @media (max-width: 720px) {
            .container { padding: 16px; }
            .header { align-items: flex-start; flex-direction: column; gap: 14px; }
            table { display: block; overflow-x: auto; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>歷史訂單</h2>
            <a href="products" class="btn">返回商城</a>
        </div>

        <%
            List<String[]> orders = (List<String[]>) request.getAttribute("orders");
            if (orders != null && !orders.isEmpty()) {
        %>
            <table>
                <thead>
                    <tr>
                        <th>訂單編號</th>
                        <th>購買商品與數量</th>
                        <th>總金額</th>
                        <th>結帳時間</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (String[] order : orders) { %>
                        <tr>
                            <td>#<%= order[0] %></td>
                            <td><%= order[3] %></td>
                            <td class="total">￥<%= order[1] %></td>
                            <td><%= order[2] %></td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="empty">目前沒有歷史訂單</div>
        <% } %>
    </div>
</body>
</html>
