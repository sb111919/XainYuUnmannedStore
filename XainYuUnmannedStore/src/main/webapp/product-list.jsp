<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.shop.entity.Product, java.util.List, java.util.Map, java.util.LinkedHashMap, java.util.ArrayList" %>
<html>
<head>
    <title>商品列表 - 購物網站</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; min-height: 100vh; padding: 24px; background: linear-gradient(135deg, #f7fbf4 0%, #edf6f2 46%, #fff8ec 100%); color: #27332f; }
        .header { display: flex; justify-content: space-between; align-items: center; background: rgba(35, 55, 43, 0.96); color: white; padding: 14px 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 14px 34px rgba(37, 68, 50, 0.18); }
        .header h1 { margin: 0; }
        .header a { color: white; text-decoration: none; margin-left: 15px; }
        .toolbar { display: flex; justify-content: space-between; align-items: center; gap: 16px; background: rgba(255,255,255,0.94); padding: 14px 16px; border-radius: 8px; box-shadow: 0 12px 32px rgba(46, 75, 60, 0.12); border: 1px solid rgba(80, 125, 95, 0.16); margin-bottom: 20px; }
        .toolbar h2 { margin: 0; font-size: 1.15rem; color: #333; }
        .category-filter { display: flex; align-items: center; gap: 8px; }
        .category-filter label { color: #555; font-weight: bold; }
        .category-filter select { min-width: 160px; padding: 8px 10px; border: 1px solid #b8cdbd; border-radius: 4px; background: white; font-size: 0.95rem; cursor: pointer; }
        .category-section { margin-bottom: 28px; }
        .category-title { margin: 0 0 12px; padding-bottom: 8px; border-bottom: 2px solid rgba(47, 125, 87, 0.25); color: #27332f; font-size: 1.25rem; }
        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .product-card { background: rgba(255,255,255,0.96); padding: 16px; border-radius: 8px; box-shadow: 0 12px 26px rgba(46, 75, 60, 0.12); border: 1px solid rgba(80, 125, 95, 0.14); }
        .product-category { display: inline-block; margin-bottom: 8px; padding: 4px 8px; background: #e6f4ea; color: #2f7d57; border-radius: 4px; font-size: 0.8rem; font-weight: bold; }
        .product-name { font-size: 1.25rem; font-weight: bold; margin-bottom: 10px; }
        .product-price { color: #c45123; font-size: 1.1rem; margin-bottom: 10px; font-weight: bold; }
        .product-desc { color: #666; font-size: 0.9rem; margin-bottom: 15px; }
        .product-stock { color: #555; font-size: 0.9rem; margin-bottom: 12px; }
        .quantity-input { width: 56px; margin-bottom: 10px; padding: 7px; border: 1px solid #b8cdbd; border-radius: 4px; }
        .add-to-cart { width: 100%; padding: 10px; background: #2f7d57; color: white; border: none; border-radius: 4px; cursor: pointer; }
        .add-to-cart:hover { background: #256644; }
        .empty-message { background: white; padding: 24px; border-radius: 8px; text-align: center; color: #666; }
        @media (max-width: 640px) {
            .header, .toolbar { align-items: stretch; flex-direction: column; }
            .header a { margin-left: 0; margin-right: 12px; }
            .category-filter { align-items: stretch; flex-direction: column; }
            .category-filter select { width: 100%; }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>商城首頁</h1>
        <div>
            <% if (session.getAttribute("user") != null) { %>
                歡迎, <%= ((com.shop.entity.User)session.getAttribute("user")).getUsername() %> |
                <% if ("admin".equals(((com.shop.entity.User)session.getAttribute("user")).getRole())) { %>
                    <a href="admin">管理後台</a> |
                <% } %>
                <a href="cart">查看購物車</a> |
                <a href="orders">歷史訂單</a> |
                <a href="logout">退出登錄</a>
            <% } else { %>
                <a href="login">登錄</a> |
                <a href="register">註冊</a>
            <% } %>
        </div>
    </div>

    <%
        List<Product> products = (List<Product>) request.getAttribute("products");
        List<String> categories = (List<String>) request.getAttribute("categories");
        String selectedCategory = (String) request.getAttribute("selectedCategory");
        boolean hasSelectedCategory = selectedCategory != null && !selectedCategory.isBlank();

        Map<String, List<Product>> groupedProducts = new LinkedHashMap<>();
        if (products != null) {
            for (Product product : products) {
                String category = product.getCategory();
                if (category == null || category.isBlank()) {
                    category = "其他";
                }
                groupedProducts.computeIfAbsent(category, key -> new ArrayList<>()).add(product);
            }
        }
    %>

    <div class="toolbar">
        <h2><%= hasSelectedCategory ? selectedCategory + "商品" : "全部商品分區" %></h2>
        <form class="category-filter" action="products" method="get">
            <label for="category">商品類型</label>
            <select id="category" name="category" onchange="this.form.submit()">
                <option value="">全部類型</option>
                <% if (categories != null) {
                    for (String category : categories) {
                %>
                    <option value="<%= category %>" <%= category.equals(selectedCategory) ? "selected" : "" %>><%= category %></option>
                <% 
                    }
                } %>
            </select>
        </form>
    </div>

    <% if (groupedProducts.isEmpty()) { %>
        <div class="empty-message">目前沒有符合條件的商品</div>
    <% } else {
        for (Map.Entry<String, List<Product>> entry : groupedProducts.entrySet()) {
    %>
        <section class="category-section">
            <h2 class="category-title"><%= entry.getKey() %></h2>
            <div class="product-grid">
                <% for (Product p : entry.getValue()) { %>
                    <div class="product-card">
                        <div class="product-category"><%= p.getCategory() %></div>
                        <div class="product-name"><%= p.getName() %></div>
                        <div class="product-price">￥<%= p.getPrice() %></div>
                        <div class="product-desc"><%= p.getDescription() %></div>
                        <div class="product-stock">庫存：<%= p.getStock() %></div>
                        <form action="cart" method="post">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="<%= p.getId() %>">
                            <input class="quantity-input" type="number" name="quantity" value="1" min="1" max="<%= p.getStock() %>">
                            <button type="submit" class="add-to-cart">加入購物車</button>
                        </form>
                    </div>
                <% } %>
            </div>
        </section>
    <%
        }
    } %>
</body>
</html>
