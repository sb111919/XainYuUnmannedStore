package com.shop.entity;

public class CartItem {
    private Product product;
    private Integer quantity;

    public CartItem() {}

    public CartItem(Product product, Integer quantity) {
        this.product = product;
        this.quantity = quantity;
    }

    // Getters and Setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    public Integer getQuantity() { return quantity; }
    public void setQuantity(Integer quantity) { this.quantity = quantity; }

    public double getSubtotal() {
        return product.getPrice().doubleValue() * quantity;
    }
}
