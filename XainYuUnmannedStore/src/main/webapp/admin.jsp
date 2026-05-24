<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shop.entity.Product, com.shop.entity.User, java.util.List" %>
<html>
<head>
    <title>管理後台 - 購物網站</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; min-height: 100vh; padding: 24px; background: linear-gradient(135deg, #f7fbf4 0%, #edf6f2 46%, #fff8ec 100%); color: #27332f; }
        .header { display: flex; justify-content: space-between; align-items: center; background: rgba(35, 55, 43, 0.96); color: white; padding: 14px 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 14px 34px rgba(37, 68, 50, 0.18); }
        .header h1 { margin: 0; font-size: 1.5rem; }
        .header a { color: white; text-decoration: none; margin-left: 16px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 16px; margin-bottom: 20px; }
        .stat-card, .panel { background: rgba(255,255,255,0.95); border: 1px solid rgba(80, 125, 95, 0.16); border-radius: 8px; box-shadow: 0 12px 32px rgba(46, 75, 60, 0.12); }
        .stat-card { padding: 18px; }
        .stat-label { color: #66746c; font-size: 0.9rem; margin-bottom: 8px; }
        .stat-value { color: #2f7d57; font-size: 1.8rem; font-weight: bold; }
        .panel { padding: 18px; margin-bottom: 20px; }
        .panel h2 { margin: 0 0 14px; font-size: 1.2rem; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }
        th, td { padding: 10px; border-bottom: 1px solid #e4e9e5; text-align: left; vertical-align: middle; }
        th { background: #eef6ef; color: #2f4a38; }
        input, select { width: 100%; min-width: 90px; padding: 7px; border: 1px solid #b8cdbd; border-radius: 4px; box-sizing: border-box; }
        .price-input { max-width: 100px; }
        .stock-input { max-width: 80px; }
        .search-form { display: flex; gap: 10px; align-items: center; margin-bottom: 14px; }
        .search-form input { max-width: 360px; }
        .actions { display: flex; gap: 8px; }
        .btn { padding: 8px 12px; border: none; border-radius: 4px; color: white; cursor: pointer; text-decoration: none; font-size: 0.9rem; white-space: nowrap; }
        .btn-save { background: #2f7d57; }
        .btn-delete { background: #c45123; }
        .btn-search { background: #2f7d57; }
        .btn-clear { background: #66746c; }
        .muted { color: #7b8780; font-size: 0.8rem; }
        .notice { margin-bottom: 16px; padding: 12px 14px; border-radius: 6px; font-weight: bold; }
        .notice-success { background: #e6f6ea; color: #21633a; border: 1px solid #b9dfc4; }
        .notice-error { background: #fdebea; color: #9d2f25; border: 1px solid #f2b8b2; }
        .table-wrap { overflow-x: auto; }
        @media (max-width: 760px) {
            .header { align-items: flex-start; flex-direction: column; gap: 10px; }
            .header a { margin-left: 0; margin-right: 14px; }
        }
    </style>
</head>
<body>
    <%
        List<Product> products = (List<Product>) request.getAttribute("products");
        List<User> users = (List<User>) request.getAttribute("users");
        List<String[]> categoryStats = (List<String[]>) request.getAttribute("categoryStats");
        List<String[]> orders = (List<String[]>) request.getAttribute("orders");
        Integer totalProducts = (Integer) request.getAttribute("totalProducts");
        Integer totalUsers = (Integer) request.getAttribute("totalUsers");
        Integer totalStock = (Integer) request.getAttribute("totalStock");
        Integer totalOrders = (Integer) request.getAttribute("totalOrders");
        java.math.BigDecimal totalSales = (java.math.BigDecimal) request.getAttribute("totalSales");
        String productKeyword = (String) request.getAttribute("productKeyword");
        String orderKeyword = (String) request.getAttribute("orderKeyword");
        String adminMessage = (String) session.getAttribute("adminMessage");
        String adminError = (String) session.getAttribute("adminError");
    %>

    <div class="header">
        <h1>管理後台</h1>
        <div>
            <a href="products">前往商城</a>
            <a href="logout">登出</a>
        </div>
    </div>

    <% if (adminMessage != null) { %>
        <div class="notice notice-success"><%= adminMessage %></div>
        <% session.removeAttribute("adminMessage"); %>
    <% } %>
    <% if (adminError != null) { %>
        <div class="notice notice-error"><%= adminError %></div>
        <% session.removeAttribute("adminError"); %>
    <% } %>

    <div class="stats">
        <div class="stat-card">
            <div class="stat-label">商品總數</div>
            <div class="stat-value"><%= totalProducts %></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">庫存總量</div>
            <div class="stat-value"><%= totalStock %></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">會員數</div>
            <div class="stat-value"><%= totalUsers %></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">訂單數</div>
            <div class="stat-value"><%= totalOrders %></div>
        </div>
        <div class="stat-card">
            <div class="stat-label">銷售額</div>
            <div class="stat-value">￥<%= totalSales %></div>
        </div>
    </div>

    <div class="panel">
        <h2>分類概況</h2>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>分類</th>
                        <th>商品數</th>
                        <th>庫存量</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (categoryStats != null) {
                        for (String[] stat : categoryStats) {
                    %>
                        <tr>
                            <td><%= stat[0] %></td>
                            <td><%= stat[1] %></td>
                            <td><%= stat[2] %></td>
                        </tr>
                    <%
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="panel">
        <h2>結帳訂單</h2>
        <form class="search-form" action="admin" method="get">
            <input type="hidden" name="productKeyword" value="<%= productKeyword == null ? "" : productKeyword %>">
            <input type="text" name="orderKeyword" value="<%= orderKeyword == null ? "" : orderKeyword %>" placeholder="搜尋訂單編號、客戶、Email、商品名稱">
            <button class="btn btn-search" type="submit">查詢訂單</button>
            <a class="btn btn-clear" href="admin?productKeyword=<%= productKeyword == null ? "" : productKeyword %>">清除</a>
        </form>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>訂單編號</th>
                        <th>客戶</th>
                        <th>Email</th>
                        <th>購買商品與數量</th>
                        <th>總金額</th>
                        <th>結帳時間</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (orders != null && !orders.isEmpty()) {
                        for (String[] order : orders) {
                    %>
                        <tr>
                            <td>#<%= order[0] %></td>
                            <td><%= order[1] %></td>
                            <td><%= order[2] == null || order[2].isBlank() ? "-" : order[2] %></td>
                            <td><%= order[5] %></td>
                            <td>￥<%= order[3] %></td>
                            <td><%= order[4] %></td>
                        </tr>
                    <%
                        }
                    } else {
                    %>
                        <tr>
                            <td colspan="6" style="text-align:center;">目前尚無結帳訂單</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="panel">
        <h2>商品管理</h2>
        <form class="search-form" action="admin" method="get">
            <input type="hidden" name="orderKeyword" value="<%= orderKeyword == null ? "" : orderKeyword %>">
            <input type="text" name="productKeyword" value="<%= productKeyword == null ? "" : productKeyword %>" placeholder="搜尋商品名稱、分類、描述">
            <button class="btn btn-search" type="submit">查詢商品</button>
            <a class="btn btn-clear" href="admin?orderKeyword=<%= orderKeyword == null ? "" : orderKeyword %>">清除</a>
        </form>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>編號</th>
                        <th>商品名稱</th>
                        <th>分類</th>
                        <th>價格</th>
                        <th>庫存</th>
                        <th>操作</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (products != null && !products.isEmpty()) {
                        int productNo = 1;
                        for (Product product : products) {
                            String formId = "productForm" + product.getId();
                    %>
                        <tr>
                            <td>
                                <%= productNo++ %>
                                <div class="muted">ID：<%= product.getId() %></div>
                            </td>
                            <td><%= product.getName() %></td>
                            <td>
                                <input form="<%= formId %>" type="text" name="category" value="<%= product.getCategory() %>" required>
                            </td>
                            <td>
                                <input form="<%= formId %>" class="price-input" type="number" name="price" value="<%= product.getPrice() %>" min="0" step="0.01" required>
                            </td>
                            <td>
                                <input form="<%= formId %>" class="stock-input" type="number" name="stock" value="<%= product.getStock() %>" min="0" required>
                            </td>
                            <td>
                                <form id="<%= formId %>" action="admin" method="post"></form>
                                <div class="actions">
                                    <input form="<%= formId %>" type="hidden" name="productId" value="<%= product.getId() %>">
                                    <button form="<%= formId %>" class="btn btn-save" type="submit" name="action" value="updateProduct">儲存</button>
                                    <button form="<%= formId %>" class="btn btn-delete" type="submit" name="action" value="deleteProduct" onclick="return confirm('確定要刪除此商品？')">刪除</button>
                                </div>
                            </td>
                        </tr>
                    <%
                        }
                    } else {
                    %>
                        <tr>
                            <td colspan="6" style="text-align:center;">目前沒有符合條件的商品</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <div class="panel">
        <h2>會員清單</h2>
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>帳號</th>
                        <th>Email</th>
                        <th>角色</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (users != null) {
                        for (User user : users) {
                    %>
                        <tr>
                            <td><%= user.getId() %></td>
                            <td><%= user.getUsername() %></td>
                            <td><%= user.getEmail() %></td>
                            <td><%= user.getRole() %></td>
                        </tr>
                    <%
                        }
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
