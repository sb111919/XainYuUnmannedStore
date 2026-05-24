<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>註冊 - 購物網站</title>
    <style>
        body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: linear-gradient(135deg, #f7fbf4 0%, #edf6f2 46%, #fff8ec 100%); color: #27332f; }
        .register-container { background: rgba(255,255,255,0.95); padding: 2rem; border-radius: 8px; box-shadow: 0 16px 40px rgba(46, 75, 60, 0.16); border: 1px solid rgba(80, 125, 95, 0.16); width: 320px; }
        h2 { text-align: center; color: #27332f; margin-top: 0; }
        .form-group { margin-bottom: 1rem; }
        label { display: block; margin-bottom: 0.5rem; color: #666; }
        input { width: 100%; padding: 0.65rem; border: 1px solid #b8cdbd; border-radius: 4px; box-sizing: border-box; }
        input:focus { outline: 2px solid rgba(47, 125, 87, 0.2); border-color: #2f7d57; }
        button { width: 100%; padding: 0.75rem; background-color: #2f7d57; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 1rem; }
        button:hover { background-color: #256644; }
        .captcha-row { display: flex; gap: 10px; align-items: center; }
        .captcha-code { min-width: 110px; padding: 0.65rem; background: #eef6ef; border: 1px solid #b8cdbd; border-radius: 4px; color: #27332f; font-weight: bold; letter-spacing: 3px; text-align: center; user-select: none; }
        .captcha-row input { flex: 1; }
        .refresh-link { display: inline-block; margin-top: 0.45rem; font-size: 0.8rem; }
        .error { color: red; font-size: 0.875rem; text-align: center; margin-bottom: 1rem; }
        .login-link { text-align: center; margin-top: 1rem; font-size: 0.875rem; }
        a { color: #c45123; font-weight: bold; }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>用戶註冊</h2>
        <% if (request.getAttribute("error") != null) { %>
            <div class="error"><%= request.getAttribute("error") %></div>
        <% } %>
        <form action="register" method="post">
            <div class="form-group">
                <label for="username">用戶名</label>
                <input type="text" id="username" name="username" value="<%= request.getAttribute("username") == null ? "" : request.getAttribute("username") %>" required>
            </div>
            <div class="form-group">
                <label for="password">密碼</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label for="email">郵箱</label>
                <input type="email" id="email" name="email" value="<%= request.getAttribute("email") == null ? "" : request.getAttribute("email") %>" required>
            </div>
            <div class="form-group">
                <label for="captcha">驗證碼</label>
                <div class="captcha-row">
                    <div class="captcha-code"><%= session.getAttribute("registerCaptcha") %></div>
                    <input type="text" id="captcha" name="captcha" maxlength="5" required>
                </div>
                <a class="refresh-link" href="register">重新產生驗證碼</a>
            </div>
            <button type="submit">註冊</button>
        </form>
        <div class="login-link">
            已有賬號？<a href="login">立即登錄</a>
        </div>
    </div>
</body>
</html>
