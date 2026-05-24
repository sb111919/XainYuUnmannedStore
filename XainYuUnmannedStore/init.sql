    CREATE DATABASE IF NOT EXISTS shopping_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

    USE shopping_db;

    -- 用戶表
    CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(100) NOT NULL,
        email VARCHAR(100),
        role VARCHAR(20) DEFAULT 'user'
    );

    -- 預設管理員帳號：admin / 1234
    INSERT INTO users (username, password, email, role)
    SELECT 'admin', '1234', 'admin@shop.local', 'admin'
    WHERE NOT EXISTS (SELECT 1 FROM users WHERE username = 'admin');

    UPDATE users
    SET password = '1234', role = 'admin'
    WHERE username = 'admin';

    -- 商品表
    CREATE TABLE IF NOT EXISTS products (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        category VARCHAR(50) NOT NULL DEFAULT '其他',
        price DECIMAL(10, 2) NOT NULL,
        description TEXT,
        stock INT DEFAULT 0
    );

    SET @category_column_exists = (
        SELECT COUNT(*)
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'products'
          AND COLUMN_NAME = 'category'
    );
    SET @add_category_column_sql = IF(
        @category_column_exists = 0,
        'ALTER TABLE products ADD COLUMN category VARCHAR(50) NOT NULL DEFAULT ''其他'' AFTER name',
        'SELECT 1'
    );
    PREPARE add_category_column_stmt FROM @add_category_column_sql;
    EXECUTE add_category_column_stmt;
    DEALLOCATE PREPARE add_category_column_stmt;

    -- 購物車項 (可選，如果存數據庫的話)
    CREATE TABLE IF NOT EXISTS cart_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        product_id INT,
        quantity INT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
    );

    -- 訂單表：記錄客戶資訊與結帳金額
    CREATE TABLE IF NOT EXISTS orders (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NULL,
        customer_name VARCHAR(50) NOT NULL,
        customer_email VARCHAR(100),
        total DECIMAL(10, 2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
    );

    -- 訂單明細：記錄購買商品與數量
    CREATE TABLE IF NOT EXISTS order_items (
        id INT AUTO_INCREMENT PRIMARY KEY,
        order_id INT NOT NULL,
        product_id INT NULL,
        product_name VARCHAR(100) NOT NULL,
        price DECIMAL(10, 2) NOT NULL,
        quantity INT NOT NULL,
        subtotal DECIMAL(10, 2) NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
    );

    -- 清理重複商品：同名商品只保留最早建立的一筆
    DROP TEMPORARY TABLE IF EXISTS duplicate_product_ids;
    CREATE TEMPORARY TABLE duplicate_product_ids AS
    SELECT p.id
    FROM products p
    JOIN (
        SELECT name, MIN(id) AS keep_id
        FROM products
        GROUP BY name
        HAVING COUNT(*) > 1
    ) duplicates ON p.name = duplicates.name
    WHERE p.id <> duplicates.keep_id;

    DELETE FROM cart_items
    WHERE id IN (
        SELECT id FROM (
            SELECT ci.id
            FROM cart_items ci
            JOIN duplicate_product_ids dpi ON ci.product_id = dpi.id
        ) matched_cart_items
    );

    DELETE FROM products
    WHERE id IN (SELECT id FROM duplicate_product_ids);

    DROP TEMPORARY TABLE IF EXISTS duplicate_product_ids;

    -- 清理早期編碼錯亂留下的舊書籍資料
    DELETE FROM cart_items
    WHERE id IN (
        SELECT id FROM (
            SELECT ci.id
            FROM cart_items ci
            JOIN products p ON ci.product_id = p.id
            WHERE HEX(p.category) = '3F3F'
        ) matched_cart_items
    );

    DELETE FROM products
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE HEX(category) = '3F3F'
        ) broken_products
    );

    -- 避免未來重複插入同名商品
    SET @product_name_index_exists = (
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'products'
          AND INDEX_NAME = 'uk_products_name'
    );
    SET @add_product_name_index_sql = IF(
        @product_name_index_exists = 0,
        'CREATE UNIQUE INDEX uk_products_name ON products (name)',
        'SELECT 1'
    );
    PREPARE add_product_name_index_stmt FROM @add_product_name_index_sql;
    EXECUTE add_product_name_index_stmt;
    DEALLOCATE PREPARE add_product_name_index_stmt;

    -- 插入初始商品資料
    INSERT INTO products (name, category, price, description, stock)
    SELECT seed.name, seed.category, seed.price, seed.description, seed.stock
    FROM (
        SELECT 'Java 編程思想' AS name, '書籍' AS category, 99.00 AS price, '經典 Java 入門書籍' AS description, 100 AS stock
        UNION ALL SELECT 'Spring Boot 實戰', '書籍', 79.50, '深入理解 Spring Boot', 50
        UNION ALL SELECT 'MySQL 從入門到精通', '書籍', 65.00, '資料庫進階指南', 80
        UNION ALL SELECT '生鮮高山高麗菜', '生鮮', 45.00, '生鮮蔬菜，清脆爽口，適合快炒與火鍋。', 120
        UNION ALL SELECT '生鮮台灣香蕉', '生鮮', 38.00, '當季水果，香甜綿密，適合早餐或點心。', 90
        UNION ALL SELECT '生鮮雞胸肉', '生鮮', 89.00, '低脂高蛋白，健身餐與家常料理都合適。', 60
        UNION ALL SELECT '生鮮鮭魚切片', '生鮮', 168.00, '冷藏海鮮，肉質細緻，適合煎烤。', 35
        UNION ALL SELECT '生鮮雞蛋十入', '生鮮', 72.00, '新鮮雞蛋，早餐與烘焙都適合。', 95
        UNION ALL SELECT '生鮮小番茄盒', '生鮮', 59.00, '酸甜多汁，可當沙拉或點心。', 75
        UNION ALL SELECT '生鮮牛奶 1L', '生鮮', 89.00, '濃醇鮮乳，冷藏配送。', 85
        UNION ALL SELECT '生鮮白蝦', '生鮮', 199.00, '鮮甜彈牙，適合清蒸與熱炒。', 30
        UNION ALL SELECT '生鮮牛肉火鍋片', '生鮮', 229.00, '薄切牛肉片，火鍋與壽喜燒皆宜。', 28
        UNION ALL SELECT '生鮮嫩豆腐', '生鮮', 25.00, '口感細緻，適合湯品與涼拌。', 110
        UNION ALL SELECT '零食洋芋片', '零食', 39.00, '酥脆鹹香，追劇與聚會都很搭。', 200
        UNION ALL SELECT '零食巧克力餅乾', '零食', 55.00, '濃郁可可風味，下午茶小點心。', 150
        UNION ALL SELECT '零食綜合堅果', '零食', 129.00, '多種堅果混合，補充能量不膩口。', 80
        UNION ALL SELECT '零食水果軟糖', '零食', 32.00, 'Q 彈果香，甜度適中。', 180
        UNION ALL SELECT '零食海苔脆片', '零食', 49.00, '薄脆海苔香氣，輕盈不油膩。', 160
        UNION ALL SELECT '零食牛肉乾', '零食', 159.00, '鹹香有嚼勁，適合宵夜點心。', 70
        UNION ALL SELECT '零食爆米花', '零食', 45.00, '焦糖香甜，電影時光必備。', 130
        UNION ALL SELECT '零食米果仙貝', '零食', 42.00, '米香酥脆，鹹甜剛好。', 140
        UNION ALL SELECT '零食布丁三入', '零食', 59.00, '滑順香甜，冰過更好吃。', 95
        UNION ALL SELECT '零食魷魚絲', '零食', 119.00, '海味濃郁，越嚼越香。', 65
        UNION ALL SELECT '家電電熱水壺', '家電', 699.00, '1.7L 快速加熱，自動斷電保護。', 25
        UNION ALL SELECT '家電微波爐', '家電', 2990.00, '多段火力設定，快速加熱日常餐點。', 12
        UNION ALL SELECT '家電空氣清淨機', '家電', 4990.00, '適合客廳與臥室，過濾粉塵與異味。', 10
        UNION ALL SELECT '家電無線吸塵器', '家電', 3990.00, '輕量手持設計，居家清潔更方便。', 15
        UNION ALL SELECT '家電電鍋', '家電', 1890.00, '多功能蒸煮，家庭料理好幫手。', 18
        UNION ALL SELECT '家電氣炸鍋', '家電', 2690.00, '少油料理，薯條雞翅快速上桌。', 16
        UNION ALL SELECT '家電吹風機', '家電', 1290.00, '溫控護髮，快速乾髮。', 30
        UNION ALL SELECT '家電除濕機', '家電', 6990.00, '雨季除濕，保持室內乾爽。', 8
        UNION ALL SELECT '飲料礦泉水六入', '飲料', 79.00, '清爽解渴，家庭常備。', 180
        UNION ALL SELECT '飲料無糖綠茶', '飲料', 25.00, '清香回甘，無糖更清爽。', 220
        UNION ALL SELECT '飲料柳橙汁', '飲料', 45.00, '酸甜果香，早餐搭配剛剛好。', 120
        UNION ALL SELECT '飲料拿鐵咖啡', '飲料', 55.00, '濃郁咖啡香，冷飲即開即喝。', 100
        UNION ALL SELECT '飲料氣泡水', '飲料', 35.00, '細緻氣泡，冰鎮更暢快。', 150
        UNION ALL SELECT '日用品抽取式衛生紙', '日用品', 119.00, '柔韌親膚，家庭必備。', 160
        UNION ALL SELECT '日用品洗衣精', '日用品', 189.00, '清潔衣物，淡雅香氣。', 90
        UNION ALL SELECT '日用品洗碗精', '日用品', 89.00, '去油力佳，容易沖洗。', 120
        UNION ALL SELECT '日用品牙膏', '日用品', 75.00, '清新薄荷，日常口腔清潔。', 130
        UNION ALL SELECT '日用品垃圾袋', '日用品', 69.00, '耐用不易破，居家整理必備。', 140
        UNION ALL SELECT '冷凍水餃', '冷凍食品', 159.00, '皮薄餡多，快速煮食。', 75
        UNION ALL SELECT '冷凍披薩', '冷凍食品', 199.00, '起司濃郁，烤箱加熱即可。', 45
        UNION ALL SELECT '冷凍薯條', '冷凍食品', 99.00, '外酥內鬆，氣炸鍋料理方便。', 80
        UNION ALL SELECT '冷凍雞塊', '冷凍食品', 139.00, '酥脆多汁，點心或配菜都適合。', 70
        UNION ALL SELECT '冷凍湯圓', '冷凍食品', 89.00, '芝麻內餡香甜，甜湯好選擇。', 65
    ) seed
    WHERE NOT EXISTS (
        SELECT 1 FROM products existing_product WHERE existing_product.name = seed.name
    );

    UPDATE products
    SET category = '書籍'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('Java 編程思想', 'Spring Boot 實戰', 'MySQL 從入門到精通')
        ) matched_products
    );

    UPDATE products
    SET category = '生鮮'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('生鮮高山高麗菜', '生鮮台灣香蕉', '生鮮雞胸肉', '生鮮鮭魚切片')
        ) matched_products
    );

    UPDATE products
    SET category = '零食'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('零食洋芋片', '零食巧克力餅乾', '零食綜合堅果', '零食水果軟糖')
        ) matched_products
    );

    UPDATE products
    SET category = '家電'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('家電電熱水壺', '家電微波爐', '家電空氣清淨機', '家電無線吸塵器')
        ) matched_products
    );

    UPDATE products
    SET category = '飲料'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('飲料礦泉水六入', '飲料無糖綠茶', '飲料柳橙汁', '飲料拿鐵咖啡', '飲料氣泡水')
        ) matched_products
    );

    UPDATE products
    SET category = '日用品'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('日用品抽取式衛生紙', '日用品洗衣精', '日用品洗碗精', '日用品牙膏', '日用品垃圾袋')
        ) matched_products
    );

    UPDATE products
    SET category = '冷凍食品'
    WHERE id IN (
        SELECT id FROM (
            SELECT id FROM products WHERE name IN ('冷凍水餃', '冷凍披薩', '冷凍薯條', '冷凍雞塊', '冷凍湯圓')
        ) matched_products
    );
