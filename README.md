#鹹魚無人商店購物網站

Java Servlet/JSP 製作的簡易無人商店購物網站，包含商品瀏覽、分類篩選、購物車、結帳、歷史訂單、會員註冊登入與管理後台。

## 技術環境

- Java 17
- Maven
- Apache Tomcat 10.1
- Jakarta Servlet 6.0
- MySQL 8
- JSP

## 主要功能

- 使用者註冊、登入、登出
- 註冊驗證碼
- 商品分類瀏覽與下拉式篩選
- 購物車新增、刪除商品
- 結帳時扣除庫存
- 使用者歷史訂單查詢
- 管理員後台
  - 商品統計、庫存統計、銷售額統計
  - 商品查詢、修改分類/價格/庫存、刪除商品
  - 訂單查詢，查看客戶資訊、商品、數量與金額
  - 會員清單

## 預設帳號

管理員帳號：

```text
帳號：admin
密碼：1234
```

一般使用者可在註冊頁自行建立。

## 資料庫設定

資料庫連線設定在：

```text
src/main/java/com/shop/util/DBUtil.java
```

目前預設值：

```text
資料庫：shopping_db
使用者：root
密碼：1234
連線：jdbc:mysql://localhost:3306/shopping_db
```

如你的 MySQL 密碼不同，請修改 `DBUtil.java` 內的 `PASSWORD`。

## 初始化資料庫

使用 MySQL Workbench 或命令列執行：

```text
init.sql
```

此檔會建立：

- `users`
- `products`
- `cart_items`
- `orders`
- `order_items`

並會新增預設管理員帳號與初始商品資料。

## 建置專案

在專案根目錄執行：

```bash
mvn clean package
```

建置完成後會產生 WAR 檔：

```text
target/shopping-webapp-1.0-SNAPSHOT.war
```

## 部署到 Tomcat

1. 將 WAR 檔放到 Tomcat 的 `webapps` 目錄。
2. 啟動或重啟 Tomcat。
3. 開啟瀏覽器進入：

```text
http://localhost:8080/shopping-webapp-1.0-SNAPSHOT/products
```

若你的 Tomcat 部署名稱不同，請以實際 context path 為準。

## 常用路由

```text
/products    商品列表
/login       登入
/register    註冊
/cart        購物車
/orders      使用者歷史訂單
/admin       管理後台
/logout      登出
```

## 專案結構

```text
src/main/java/com/shop/controller   Servlet 控制器
src/main/java/com/shop/dao          DAO 介面
src/main/java/com/shop/dao/impl     DAO 實作
src/main/java/com/shop/entity       Entity 類別
src/main/java/com/shop/util         資料庫與編碼工具
src/main/webapp                     JSP 頁面
init.sql                            資料庫初始化腳本
pom.xml                             Maven 設定
```

## 注意事項

- 若修改 JSP 後 Tomcat 仍顯示舊錯誤，可清除 Tomcat 的 `work` 目錄快取後重啟。
- 若資料庫已有舊資料，`init.sql` 會盡量避免重複插入同名商品。
- 目前密碼為明文儲存，適合作業或展示用途；正式環境應改為雜湊密碼。
