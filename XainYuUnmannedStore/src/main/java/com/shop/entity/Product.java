package com.shop.entity;

import java.math.BigDecimal;

public class Product {
    private Integer id;
    private String name;
    private String category;
    private BigDecimal price;
    private String description;
    private Integer stock;

    public Product() {}

    public Product(Integer id, String name, String category, BigDecimal price, String description, Integer stock) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.description = description;
        this.stock = stock;
    }

    // Getters and Setters
    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }
}
