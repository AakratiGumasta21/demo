-- ============================================================
-- FLIPKART OLAP DATA WAREHOUSE SCHEMA (PostgreSQL)
-- Star Schema: 1 Fact Table + 5 Dimension Tables
-- ============================================================

DROP TABLE IF EXISTS fact_orders CASCADE;
DROP TABLE IF EXISTS dim_user CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_payment CASCADE;
DROP TABLE IF EXISTS dim_logistic CASCADE;

-- ------------------------------------------------------------
-- DIMENSION 1: dim_user
-- ------------------------------------------------------------
CREATE TABLE dim_user (
    user_key      SERIAL PRIMARY KEY,   -- surrogate key
    user_id       INT UNIQUE NOT NULL,  -- original OLTP id
    name          VARCHAR(100),
    gender        VARCHAR(10),
    age_group     VARCHAR(20),          -- derived: 18-25, 26-35, 36-45, 46+
    city          VARCHAR(50),
    state         VARCHAR(50),
    signup_date   DATE
);

-- ------------------------------------------------------------
-- DIMENSION 2: dim_product
-- ------------------------------------------------------------
CREATE TABLE dim_product (
    product_key   SERIAL PRIMARY KEY,
    product_id    INT NOT NULL,
    product_name  VARCHAR(100),
    category      VARCHAR(50),
    brand         VARCHAR(50),
    UNIQUE (product_id, product_name, brand)
);

-- ------------------------------------------------------------
-- DIMENSION 3: dim_date
-- ------------------------------------------------------------
CREATE TABLE dim_date (
    date_key      INT PRIMARY KEY,      -- format YYYYMMDD
    full_date     DATE NOT NULL UNIQUE,
    day           INT,
    month         INT,
    month_name    VARCHAR(15),
    quarter       INT,
    year          INT,
    day_name      VARCHAR(15),
    is_weekend    BOOLEAN
);

-- ------------------------------------------------------------
-- DIMENSION 4: dim_payment
-- ------------------------------------------------------------
CREATE TABLE dim_payment (
    payment_key     SERIAL PRIMARY KEY,
    payment_mode    VARCHAR(30),
    payment_status  VARCHAR(20),
    coupon_code     VARCHAR(20),
    UNIQUE (payment_mode, payment_status, coupon_code)
);

-- ------------------------------------------------------------
-- DIMENSION 5: dim_logistic
-- ------------------------------------------------------------
CREATE TABLE dim_logistic (
    logistic_key        SERIAL PRIMARY KEY,
    courier_partner      VARCHAR(50),
    warehouse_location   VARCHAR(50),
    delivery_status       VARCHAR(30),
    UNIQUE (courier_partner, warehouse_location, delivery_status)
);

-- ------------------------------------------------------------
-- FACT TABLE: fact_orders
-- ------------------------------------------------------------
CREATE TABLE fact_orders (
    fact_id            SERIAL PRIMARY KEY,
    order_id           INT NOT NULL,          -- original OLTP order_id (traceability)
    user_key           INT REFERENCES dim_user(user_key),
    product_key        INT REFERENCES dim_product(product_key),
    date_key           INT REFERENCES dim_date(date_key),
    payment_key        INT REFERENCES dim_payment(payment_key),
    logistic_key        INT REFERENCES dim_logistic(logistic_key),
    order_status        VARCHAR(20),
    quantity             INT,
    price                 NUMERIC(10,2),
    amount_paid           NUMERIC(10,2),
    discount_applied      NUMERIC(10,2),
    estimated_delivery_days INT,
    actual_delivery_days   INT,
    rating                 INT               -- NULL if no review
);

-- Indexes for faster analytical queries
CREATE INDEX idx_fact_user ON fact_orders(user_key);
CREATE INDEX idx_fact_product ON fact_orders(product_key);
CREATE INDEX idx_fact_date ON fact_orders(date_key);
CREATE INDEX idx_fact_payment ON fact_orders(payment_key);
CREATE INDEX idx_fact_logistic ON fact_orders(logistic_key);