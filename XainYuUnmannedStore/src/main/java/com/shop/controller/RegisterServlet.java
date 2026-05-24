package com.shop.controller;

import com.shop.dao.UserDao;
import com.shop.dao.impl.UserDaoImpl;
import com.shop.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.security.SecureRandom;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDao userDao = new UserDaoImpl();
    private static final String CAPTCHA_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        generateCaptcha(req);
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String email = req.getParameter("email");
        String captchaInput = req.getParameter("captcha");
        HttpSession session = req.getSession();
        String captchaCode = (String) session.getAttribute("registerCaptcha");

        if (captchaCode == null || captchaInput == null || !captchaCode.equalsIgnoreCase(captchaInput.trim())) {
            req.setAttribute("error", "驗證碼錯誤，請重新輸入");
            req.setAttribute("username", username);
            req.setAttribute("email", email);
            generateCaptcha(req);
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
            return;
        }

        User user = new User();
        user.setUsername(username);
        user.setPassword(password);
        user.setEmail(email);
        user.setRole("user");

        try {
            if (userDao.findByUsername(username) != null) {
                req.setAttribute("error", "用戶名已存在");
                req.setAttribute("username", username);
                req.setAttribute("email", email);
                generateCaptcha(req);
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
            } else {
                userDao.save(user);
                session.removeAttribute("registerCaptcha");
                resp.sendRedirect(req.getContextPath() + "/login");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    private void generateCaptcha(HttpServletRequest req) {
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < 5; i++) {
            code.append(CAPTCHA_CHARS.charAt(RANDOM.nextInt(CAPTCHA_CHARS.length())));
        }
        req.getSession().setAttribute("registerCaptcha", code.toString());
    }
}
