<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>登錄 - 購物網站</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: linear-gradient(135deg, #f7fbf4 0%, #edf6f2 46%, #fff8ec 100%); color: #27332f; }
        .login-container { background: rgba(255,255,255,0.95); padding: 2rem; border-radius: 8px; box-shadow: 0 16px 40px rgba(46, 75, 60, 0.16); border: 1px solid rgba(80, 125, 95, 0.16); width: 320px; }
        h2 { text-align: center; color: #27332f; margin-top: 0; }
        .form-group { margin-bottom: 1rem; }
        label { display: block; margin-bottom: 0.5rem; color: #666; }
        input { width: 100%; padding: 0.65rem; border: 1px solid #b8cdbd; border-radius: 4px; box-sizing: border-box; }
        input:focus { outline: 2px solid rgba(47, 125, 87, 0.2); border-color: #2f7d57; }
        button { width: 100%; padding: 0.75rem; background-color: #2f7d57; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; }
        button:hover { background-color: #256644; }
        .admin-login { margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #dce8df; }
        .admin-title { margin-bottom: 0.65rem; color: #555; font-size: 0.9rem; font-weight: bold; text-align: center; }
        .admin-button { background-color: #c45123; }
        .admin-button:hover { background-color: #a6401b; }
        .error { color: red; font-size: 0.875rem; text-align: center; margin-bottom: 1rem; }
        .register-link { text-align: center; margin-top: 1rem; font-size: 0.875rem; }
        a { color: #c45123; font-weight: bold; }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>用戶登錄</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form id="loginForm" action="login" method="post">
            <div class="form-group">
                <label for="username">用戶名</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">密碼</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit">登錄</button>
        </form>
        <div class="admin-login">
            <div class="admin-title">管理員入口</div>
            <button type="button" class="admin-button" onclick="loginAsAdmin()">管理員登入</button>
        </div>
        <div class="register-link">
            還沒有賬號？<a href="register">立即註冊</a>
        </div>
    </div>
    <script>
        function loginAsAdmin() {
            document.getElementById("username").value = "admin";
            document.getElementById("password").value = "1234";
            document.getElementById("loginForm").submit();
        }
    </script>
</body>
</html>
