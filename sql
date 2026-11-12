/*
PROJECT: OLIST E-COMMERCE DATA ANALYSIS
DATABASE: MySQL - olist_ecommerce
DATASET: Brazilian E-Commerce Public Dataset (2016-2018)

30 business-focused SQL questions and queries.
Run each query independently in MySQL Workbench.

DATA NOTES:
- payment_value is payment value, not net revenue or profit.
- order_items.price excludes freight.
- Reviews are associated with orders, not individual products.
- customer_id is order-specific; customer_unique_id identifies a customer across orders.
- Delivery calculations exclude rows where required timestamps are missing.
*/

USE olist_ecommerce;

-- =========================================================
-- SECTION 1: ORDER OVERVIEW
-- =========================================================

-- Q01. How many orders are present in the dataset?
-- Concepts: COUNT
SELECT COUNT(*) AS total_orders
FROM orders;


-- Q02. How many unique customers are represented in the dataset?
-- Concepts: COUNT(DISTINCT)
SELECT COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- Q03. How many orders are there for each order status?
-- Concepts: GROUP BY, COUNT, ORDER BY
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- Q04. How many orders were placed each month?
-- Concepts: YEAR, MONTH, GROUP BY
SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(*) AS total_orders
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
ORDER BY order_year, order_month;


-- Q05. What is the monthly order growth percentage compared with the previous month?
-- Concepts: CTE, LAG, NULLIF
WITH monthly_orders AS (
    SELECT
        YEAR(order_purchase_timestamp) AS order_year,
        MONTH(order_purchase_timestamp) AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    WHERE order_purchase_timestamp IS NOT NULL
    GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)
),
monthly_comparison AS (
    SELECT
        order_year,
        order_month,
        total_orders,
        LAG(total_orders) OVER (ORDER BY order_year, order_month) AS previous_month_orders
    FROM monthly_orders
)
SELECT
    order_year,
    order_month,
    total_orders,
    previous_month_orders,
    ROUND(
        (total_orders - previous_month_orders) * 100.0
        / NULLIF(previous_month_orders, 0),
        2
    ) AS monthly_growth_percentage
FROM monthly_comparison
ORDER BY order_year, order_month;


-- =========================================================
-- SECTION 2: CUSTOMER ANALYSIS
-- =========================================================

-- Q06. How many orders has each unique customer placed?
-- Concepts: JOIN, GROUP BY, COUNT
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
ORDER BY total_orders DESC;


-- Q07. Which customers have placed more than one order?
-- Concepts: JOIN, GROUP BY, HAVING
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;


-- Q08. Who are the top 5 customers by total payment value?
-- Concepts: JOIN, SUM, GROUP BY, ORDER BY, LIMIT
SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN order_payments AS p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY total_payment_value DESC
LIMIT 5;


-- Q09. Which customers have a total payment value greater than 10,000?
-- Concepts: JOIN, SUM, GROUP BY, HAVING
SELECT
    c.customer_unique_id,
    ROUND(SUM(p.payment_value), 2) AS total_payment_value
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
JOIN order_payments AS p ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
HAVING SUM(p.payment_value) > 10000
ORDER BY total_payment_value DESC;


-- Q10. Which customers have placed orders in more than one calendar month?
-- Concepts: JOIN, COUNT(DISTINCT), DATE_FORMAT, HAVING
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders,
    COUNT(DISTINCT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) AS active_months
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')) > 1
ORDER BY total_orders DESC;


-- Q11. Are there customer records that are not linked to an order?
-- Concepts: LEFT JOIN, IS NULL
SELECT c.customer_id, c.customer_unique_id
FROM customers AS c
LEFT JOIN orders AS o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;


-- =========================================================
-- SECTION 3: PAYMENT ANALYSIS
-- =========================================================

-- Q12. What is the total payment value for each order?
-- Concepts: SUM, GROUP BY
SELECT
    order_id,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM order_payments
GROUP BY order_id
ORDER BY total_payment_value DESC;


-- Q13. What is the average order value based on total payment value per order?
-- Concepts: CTE, SUM, AVG
WITH order_totals AS (
    SELECT order_id, SUM(payment_value) AS order_payment_value
    FROM order_payments
    GROUP BY order_id
)
SELECT ROUND(AVG(order_payment_value), 2) AS average_order_value
FROM order_totals;


-- =========================================================
-- SECTION 4: PRODUCT AND CATEGORY ANALYSIS
-- =========================================================

-- Q14. How many order items were included in each order?
-- Concepts: COUNT, GROUP BY
SELECT order_id, COUNT(*) AS total_order_items
FROM order_items
GROUP BY order_id
ORDER BY total_order_items DESC;


-- Q15. How many units of each product were sold?
-- Concepts: COUNT, GROUP BY
SELECT product_id, COUNT(*) AS units_sold
FROM order_items
GROUP BY product_id
ORDER BY units_sold DESC;


-- Q16. What is the total item-price value generated by each product?
-- Note: Item price excludes freight; this is not profit.
-- Concepts: SUM, GROUP BY
SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_item_price
FROM order_items
GROUP BY product_id
ORDER BY total_item_price DESC;


-- Q17. Which products have total item-price value greater than 10,000?
-- Concepts: SUM, GROUP BY, HAVING
SELECT
    product_id,
    ROUND(SUM(price), 2) AS total_item_price
FROM order_items
GROUP BY product_id
HAVING SUM(price) > 10000
ORDER BY total_item_price DESC;


-- Q18. Which are the top 5 product categories by units sold?
-- Concepts: JOIN, COUNT, GROUP BY, ORDER BY, LIMIT
SELECT
    ct.product_category_name_english,
    COUNT(*) AS units_sold
FROM order_items AS oi
JOIN products AS p ON oi.product_id = p.product_id
JOIN category_translation AS ct ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY units_sold DESC
LIMIT 5;


-- Q19. Which products have the second-highest number of units sold?
-- DENSE_RANK retains ties at the second distinct quantity.
-- Concepts: CTE, DENSE_RANK
WITH product_quantity AS (
    SELECT product_id, COUNT(*) AS units_sold
    FROM order_items
    GROUP BY product_id
),
ranked_products AS (
    SELECT
        product_id,
        units_sold,
        DENSE_RANK() OVER (ORDER BY units_sold DESC) AS quantity_rank
    FROM product_quantity
)
SELECT product_id, units_sold
FROM ranked_products
WHERE quantity_rank = 2
ORDER BY product_id;


-- Q20. Which products have the second-highest total item-price value?
-- Concepts: CTE, DENSE_RANK
WITH product_sales AS (
    SELECT product_id, SUM(price) AS total_item_price
    FROM order_items
    GROUP BY product_id
),
ranked_sales AS (
    SELECT
        product_id,
        total_item_price,
        DENSE_RANK() OVER (ORDER BY total_item_price DESC) AS sales_rank
    FROM product_sales
)
SELECT product_id, ROUND(total_item_price, 2) AS total_item_price
FROM ranked_sales
WHERE sales_rank = 2
ORDER BY product_id;


-- Q21. Which products have never appeared in an order that has a review?
-- Reviews belong to orders, not individual products.
-- Concepts: LEFT JOIN, GROUP BY, HAVING
SELECT oi.product_id
FROM order_items AS oi
LEFT JOIN order_reviews AS r ON oi.order_id = r.order_id
GROUP BY oi.product_id
HAVING COUNT(r.order_id) = 0;


-- Q22. Which products have never been sold?
-- Concepts: LEFT JOIN, IS NULL
SELECT p.product_id
FROM products AS p
LEFT JOIN order_items AS oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;


-- =========================================================
-- SECTION 5: SELLER ANALYSIS
-- =========================================================

-- Q23. What is the total item-price value associated with each seller?
-- Note: This is item price, not seller profit or payout.
-- Concepts: SUM, GROUP BY
SELECT
    seller_id,
    ROUND(SUM(price), 2) AS total_item_price
FROM order_items
GROUP BY seller_id
ORDER BY total_item_price DESC;


-- Q24. Which are the top 5 sellers by average associated order review score?
-- IMPORTANT: Reviews are order-level. If an order contains multiple sellers,
-- the same review score is associated with each seller in that order.
-- This is not a direct seller rating.
-- Concepts: JOIN, AVG, COUNT(DISTINCT), GROUP BY, ORDER BY, LIMIT
SELECT
    s.seller_id,
    ROUND(AVG(r.review_score), 2) AS average_associated_order_review_score,
    COUNT(DISTINCT oi.order_id) AS orders_with_reviews
FROM sellers AS s
JOIN order_items AS oi ON s.seller_id = oi.seller_id
JOIN order_reviews AS r ON oi.order_id = r.order_id
GROUP BY s.seller_id
ORDER BY average_associated_order_review_score DESC, orders_with_reviews DESC
LIMIT 5;


-- =========================================================
-- SECTION 6: REVIEW ANALYSIS
-- =========================================================

-- Q25. What is the review-score distribution?
-- Concepts: COUNT, GROUP BY, ORDER BY
SELECT review_score, COUNT(*) AS total_reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;


-- Q26. What is the average review score for each order status?
-- Concepts: JOIN, AVG, GROUP BY
SELECT
    o.order_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM orders AS o
JOIN order_reviews AS r ON o.order_id = r.order_id
GROUP BY o.order_status
ORDER BY average_review_score DESC;


-- Q27. Which orders do not have a matching review record?
-- Concepts: LEFT JOIN, IS NULL
SELECT o.order_id
FROM orders AS o
LEFT JOIN order_reviews AS r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;


-- =========================================================
-- SECTION 7: DELIVERY PERFORMANCE
-- =========================================================

-- Q28. What percentage of delivered orders arrived after the estimated date?
-- Denominator includes only orders with both actual and estimated delivery dates.
-- Concepts: CASE, SUM, NULLIF, ROUND
SELECT
    ROUND(
        100.0 * SUM(
            CASE
                WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS late_delivery_percentage
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- Q29. What is the average number of calendar days from purchase to customer delivery?
-- Concepts: AVG, DATEDIFF
SELECT
    ROUND(
        AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL;


-- =========================================================
-- SECTION 8: GEOGRAPHICAL ANALYSIS
-- =========================================================

-- Q30. What is the average order payment value by customer state?
-- Calculate payment per order first, then average order totals within each state.
-- Concepts: CTE, JOIN, SUM, AVG, GROUP BY
WITH order_payment_totals AS (
    SELECT order_id, SUM(payment_value) AS order_payment_value
    FROM order_payments
    GROUP BY order_id
)
SELECT
    c.customer_state,
    ROUND(AVG(opt.order_payment_value), 2) AS average_order_payment_value,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN order_payment_totals AS opt ON o.order_id = opt.order_id
GROUP BY c.customer_state
ORDER BY average_order_payment_value DESC;
