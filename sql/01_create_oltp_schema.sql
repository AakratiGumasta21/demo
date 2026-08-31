-- ============================================================
-- FLIPKART OLTP DATABASE SCHEMA
-- Raw transactional tables with PK/FK relationships
-- ============================================================

DROP DATABASE IF EXISTS flipkart_oltp;
CREATE DATABASE flipkart_oltp;
USE flipkart_oltp;

-- ------------------------------------------------------------
-- 1. USER_INFO
-- ------------------------------------------------------------
CREATE TABLE user_info (
    user_id      INT PRIMARY KEY,
    name         VARCHAR(100) NOT NULL,
    email        VARCHAR(150),
    phone        VARCHAR(15),
    gender       VARCHAR(10),
    dob          DATE,
    city         VARCHAR(50),
    state        VARCHAR(50),
    pincode      INT,
    signup_date  DATE
);

-- ------------------------------------------------------------
-- 2. ORDER_INFO
-- ------------------------------------------------------------
CREATE TABLE order_info (
    order_id      INT PRIMARY KEY,
    user_id       INT,
    product_id    INT,
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    brand         VARCHAR(50),
    price         DECIMAL(10,2),
    quantity      INT,
    order_date    DATE,
    order_status  VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES user_info(user_id)
);

-- ------------------------------------------------------------
-- 3. PAYMENT_INFO
-- ------------------------------------------------------------
CREATE TABLE payment_info (
    payment_id        INT PRIMARY KEY,
    order_id          INT,
    payment_mode      VARCHAR(30),
    payment_status    VARCHAR(20),
    amount_paid       DECIMAL(10,2),
    transaction_date  DATETIME,
    discount_applied  DECIMAL(10,2),
    coupon_code       VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES order_info(order_id)
);

-- ------------------------------------------------------------
-- 4. LOGISTIC_INFO
-- ------------------------------------------------------------
CREATE TABLE logistic_info (
    shipment_id         INT PRIMARY KEY,
    order_id             INT,
    courier_partner      VARCHAR(50),
    warehouse_location   VARCHAR(50),
    dispatch_date        DATE NULL,
    delivery_date        DATE NULL,
    delivery_status      VARCHAR(30),
    estimated_days        INT,
    FOREIGN KEY (order_id) REFERENCES order_info(order_id)
);

-- ------------------------------------------------------------
-- 5. RATING_REVIEW
-- ------------------------------------------------------------
CREATE TABLE rating_review (
    review_id     INT PRIMARY KEY,
    order_id      INT,
    user_id       INT,
    product_id    INT,
    rating        INT,
    review_text   TEXT,
    review_date   DATE,
    FOREIGN KEY (order_id) REFERENCES order_info(order_id),
    FOREIGN KEY (user_id) REFERENCES user_info(user_id)
);

-- ------------------------------------------------------------
-- Helpful indexes for faster joins later (ETL performance)
-- ------------------------------------------------------------
CREATE INDEX idx_order_user ON order_info(user_id);
CREATE INDEX idx_payment_order ON payment_info(order_id);
CREATE INDEX idx_logistic_order ON logistic_info(order_id);
CREATE INDEX idx_review_order ON rating_review(order_id);
