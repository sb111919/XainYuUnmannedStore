package com.shop.controller;

import com.shop.dao.ProductDao;
import com.shop.dao.impl.ProductDaoImpl;
import com.shop.entity.Product;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/products")
public class ProductListServlet extends HttpServlet {
    private ProductDao productDao = new ProductDaoImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String category = req.getParameter("category");
            List<Product> products = (category == null || category.isBlank())
                    ? productDao.findAll()
                    : productDao.findByCategory(category);
            List<String> categories = productDao.findCategories();
            req.setAttribute("products", products);
            req.setAttribute("categories", categories);
            req.setAttribute("selectedCategory", category);
            req.getRequestDispatcher("/product-list.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
