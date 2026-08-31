-- ============================================================
-- FLIPKART DATA WAREHOUSE — 10 SQL ANALYSIS QUERIES
-- Database: flipkart_dwh (PostgreSQL)
-- Purpose: Solve real business questions using the Star Schema
-- ============================================================


-- ============================================================
-- QUERY 1: Top 10 highest revenue-generating products
-- Concept: Basic SELECT, WHERE, GROUP BY, ORDER BY, LIMIT
-- Business Question: Which products should we stock more of?
-- ============================================================
SELECT
    dp.product_name,
    dp.category,
    dp.brand,
    SUM(fo.amount_paid) AS total_revenue,
    COUNT(*) AS total_orders
FROM fact_orders fo
JOIN dim_product dp ON fo.product_key = dp.product_key
WHERE fo.order_status = 'Delivered'
GROUP BY dp.product_name, dp.category, dp.brand
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- QUERY 2: City-wise total revenue and average order value
-- Concept: GROUP BY, Aggregate functions (SUM, AVG, COUNT)
-- Business Question: Which cities are our best markets?
-- ============================================================
SELECT
    du.city,
    du.state,
    COUNT(*) AS total_orders,
    SUM(fo.amount_paid) AS total_revenue,
    ROUND(AVG(fo.amount_paid), 2) AS avg_order_value
FROM fact_orders fo
JOIN dim_user du ON fo.user_key = du.user_key
WHERE fo.order_status = 'Delivered'
GROUP BY du.city, du.state
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- QUERY 3: Complete order history for a specific user
-- Concept: JOIN (2 tables), WHERE filter
-- Business Question: What has a specific customer ordered? (Customer support use-case)
-- ============================================================
SELECT
    du.name,
    dp.product_name,
    fo.quantity,
    fo.amount_paid,
    dd.full_date AS order_date,
    fo.order_status
FROM fact_orders fo
JOIN dim_user du ON fo.user_key = du.user_key
JOIN dim_product dp ON fo.product_key = dp.product_key
JOIN dim_date dd ON fo.date_key = dd.date_key
WHERE du.user_id = 1
ORDER BY dd.full_date DESC;


-- ============================================================
-- QUERY 4: Payment mode performance combined with delivery status
-- Concept: Multi-table JOIN (4 tables), GROUP BY
-- Business Question: Do certain payment modes correlate with delivery issues?
-- ============================================================
SELECT
    dpay.payment_mode,
    dl.delivery_status,
    COUNT(*) AS order_count,
    ROUND(AVG(fo.amount_paid), 2) AS avg_order_value
FROM fact_orders fo
JOIN dim_payment dpay ON fo.payment_key = dpay.payment_key
JOIN dim_logistic dl ON fo.logistic_key = dl.logistic_key
GROUP BY dpay.payment_mode, dl.delivery_status
ORDER BY dpay.payment_mode, order_count DESC;


-- ============================================================
-- QUERY 5: Users who spent more than the average customer
-- Concept: Subquery (scalar subquery in WHERE clause)
-- Business Question: Who are our high-value customers? (for loyalty programs)
-- ============================================================
SELECT
    du.name,
    du.city,
    SUM(fo.amount_paid) AS total_spent
FROM fact_orders fo
JOIN dim_user du ON fo.user_key = du.user_key
WHERE fo.order_status = 'Delivered'
GROUP BY du.name, du.city
HAVING SUM(fo.amount_paid) > (
    SELECT AVG(user_total)
    FROM (
        SELECT SUM(amount_paid) AS user_total
        FROM fact_orders
        WHERE order_status = 'Delivered'
        GROUP BY user_key
    ) AS user_totals
)
ORDER BY total_spent DESC
LIMIT 15;


-- ============================================================
-- QUERY 6: Month-wise running total of revenue (sales trend over time)
-- Concept: Window Function (SUM() OVER with ORDER BY = running total)
-- Business Question: How is our revenue growing month over month?
-- ============================================================
SELECT
    dd.year,
    dd.month,
    dd.month_name,
    SUM(fo.amount_paid) AS monthly_revenue,
    SUM(SUM(fo.amount_paid)) OVER (ORDER BY dd.year, dd.month) AS running_total_revenue
FROM fact_orders fo
JOIN dim_date dd ON fo.date_key = dd.date_key
WHERE fo.order_status = 'Delivered'
GROUP BY dd.year, dd.month, dd.month_name
ORDER BY dd.year, dd.month;


-- ============================================================
-- QUERY 7: Categorize delivery speed as Fast / Medium / Slow
-- Concept: CASE WHEN (conditional logic)
-- Business Question: How is our overall delivery performance?
-- ============================================================
SELECT
    CASE
        WHEN actual_delivery_days <= 3 THEN 'Fast'
        WHEN actual_delivery_days BETWEEN 4 AND 6 THEN 'Medium'
        ELSE 'Slow'
    END AS delivery_speed,
    COUNT(*) AS order_count,
    ROUND(AVG(actual_delivery_days), 1) AS avg_days
FROM fact_orders
WHERE actual_delivery_days IS NOT NULL
GROUP BY delivery_speed
ORDER BY order_count DESC;


-- ============================================================
-- QUERY 8: Categories with average rating below 3.5 (quality concern)
-- Concept: JOIN + GROUP BY + HAVING (filter on aggregate result)
-- Business Question: Which product categories need quality improvement?
-- ============================================================
SELECT
    dp.category,
    ROUND(AVG(fo.rating), 2) AS avg_rating,
    COUNT(fo.rating) AS total_reviews
FROM fact_orders fo
JOIN dim_product dp ON fo.product_key = dp.product_key
WHERE fo.rating IS NOT NULL
GROUP BY dp.category
HAVING AVG(fo.rating) < 3.5
ORDER BY avg_rating ASC;


-- ============================================================
-- QUERY 9: Monthly order trend with year-over-year comparison
-- Concept: Date functions, GROUP BY, ORDER BY
-- Business Question: Is there seasonality in our orders (e.g., festive months)?
-- ============================================================
SELECT
    dd.year,
    dd.month_name,
    dd.month,
    COUNT(*) AS total_orders,
    SUM(fo.quantity) AS total_units_sold
FROM fact_orders fo
JOIN dim_date dd ON fo.date_key = dd.date_key
GROUP BY dd.year, dd.month_name, dd.month
ORDER BY dd.year, dd.month;


-- ============================================================
-- QUERY 10: Best-selling product per city (Top product by city)
-- Concept: CTE + Window Function (RANK)
-- Business Question: What should each regional warehouse stock the most?
-- ============================================================
WITH city_product_sales AS (
    SELECT
        du.city,
        dp.product_name,
        dp.category,
        SUM(fo.amount_paid) AS revenue,
        RANK() OVER (PARTITION BY du.city ORDER BY SUM(fo.amount_paid) DESC) AS rnk
    FROM fact_orders fo
    JOIN dim_user du ON fo.user_key = du.user_key
    JOIN dim_product dp ON fo.product_key = dp.product_key
    WHERE fo.order_status = 'Delivered'
    GROUP BY du.city, dp.product_name, dp.category
)
SELECT city, product_name, category, revenue
FROM city_product_sales
WHERE rnk = 1
ORDER BY revenue DESC
LIMIT 15;
