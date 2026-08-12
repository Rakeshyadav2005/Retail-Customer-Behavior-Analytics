USE retail_analytics;

-- ==========================================================
-- BUSINESS ANALYSIS PRACTICE
-- Total Problems: 18
-- ==========================================================


-- ==========================================================
-- BUSINESS ANALYSIS 1
-- Business Problem:
-- The marketing team wants to understand the conversion
-- funnel for each product.
--
-- Return:
-- 1. itemid
-- 2. total_views
-- 3. total_addtocarts
-- 4. total_transactions
-- 5. view_to_addtocart_rate
-- 6. view_to_transaction_rate
--
-- Include products with at least 100 views.
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS total_views,
        SUM(CASE WHEN event = 'addtocart' THEN 1 ELSE 0 END) AS total_addtocarts,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS total_transactions
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    total_views,
    total_addtocarts,
    total_transactions,
    ROUND(100.0 * total_addtocarts / NULLIF(total_views, 0), 2)
        AS view_to_addtocart_rate,
    ROUND(100.0 * total_transactions / NULLIF(total_views, 0), 2)
        AS view_to_transaction_rate
FROM ProductMetrics
WHERE total_views >= 100
ORDER BY view_to_transaction_rate DESC,
         total_views DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 2
-- Business Problem:
-- Identify products with high customer interest but poor
-- conversion.
--
-- Conditions:
-- 1. At least 500 views
-- 2. At least 20 add-to-carts
-- 3. Transaction conversion rate below 1%
--
-- Return:
-- itemid, views, addtocarts, transactions, conversion_rate
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS views,
        SUM(CASE WHEN event = 'addtocart' THEN 1 ELSE 0 END) AS addtocarts,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS transactions
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    views,
    addtocarts,
    transactions,
    ROUND(100.0 * transactions / NULLIF(views, 0), 2)
        AS conversion_rate
FROM ProductMetrics
WHERE views >= 500
  AND addtocarts >= 20
  AND transactions / NULLIF(views, 0) < 0.01
ORDER BY views DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 3
-- Business Problem:
-- Identify visitors who are highly engaged but have never
-- completed a transaction.
--
-- Conditions:
-- 1. At least 30 events
-- 2. At least 10 distinct products
-- 3. Zero transactions
--
-- Return:
-- visitorid, total_events, distinct_products
-- ==========================================================

WITH VisitorMetrics AS (
    SELECT
        visitorid,
        COUNT(*) AS total_events,
        COUNT(DISTINCT itemid) AS distinct_products,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transactions
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    total_events,
    distinct_products
FROM VisitorMetrics
WHERE total_events >= 30
  AND distinct_products >= 10
  AND transactions = 0
ORDER BY total_events DESC,
         distinct_products DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 4
-- Business Problem:
-- Find repeat customers who purchased multiple products.
--
-- Conditions:
-- 1. At least 2 transactions
-- 2. At least 2 distinct purchased products
--
-- Return:
-- visitorid
-- transaction_count
-- purchased_products
-- ==========================================================

SELECT
    visitorid,
    COUNT(*) AS transaction_count,
    COUNT(DISTINCT itemid) AS purchased_products
FROM events
WHERE event = 'transaction'
GROUP BY visitorid
HAVING transaction_count >= 2
   AND purchased_products >= 2
ORDER BY transaction_count DESC,
         purchased_products DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 5
-- Business Problem:
-- Find products where add-to-cart activity is high but
-- transaction activity is low.
--
-- Conditions:
-- 1. At least 50 add-to-carts
-- 2. Transactions less than 5
--
-- Return:
-- itemid
-- addtocart_count
-- transaction_count
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'addtocart' THEN 1 ELSE 0 END)
            AS addtocart_count,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transaction_count
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    addtocart_count,
    transaction_count
FROM ProductMetrics
WHERE addtocart_count >= 50
  AND transaction_count < 5
ORDER BY addtocart_count DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 6
-- Business Problem:
-- Identify the top 10 products based on transaction count.
--
-- Return:
-- itemid
-- transaction_count
-- transaction_rank
--
-- Use a window function.
-- ==========================================================

WITH ProductTransactions AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transaction_count
    FROM events
    GROUP BY itemid
),
RankedProducts AS (
    SELECT
        itemid,
        transaction_count,
        RANK() OVER (
            ORDER BY transaction_count DESC
        ) AS transaction_rank
    FROM ProductTransactions
)
SELECT
    itemid,
    transaction_count,
    transaction_rank
FROM RankedProducts
WHERE transaction_rank <= 10
ORDER BY transaction_rank;


-- ==========================================================
-- BUSINESS ANALYSIS 7
-- Business Problem:
-- Identify the top 3 products for each event type.
--
-- Return:
-- event
-- itemid
-- event_count
-- rank_within_event
--
-- This helps management understand which products dominate
-- views, add-to-carts, and transactions.
-- ==========================================================

WITH ProductEvents AS (
    SELECT
        event,
        itemid,
        COUNT(*) AS event_count
    FROM events
    GROUP BY event, itemid
),
RankedProducts AS (
    SELECT
        event,
        itemid,
        event_count,
        DENSE_RANK() OVER (
            PARTITION BY event
            ORDER BY event_count DESC
        ) AS rank_within_event
    FROM ProductEvents
)
SELECT
    event,
    itemid,
    event_count,
    rank_within_event
FROM RankedProducts
WHERE rank_within_event <= 3
ORDER BY event,
         rank_within_event;


-- ==========================================================
-- BUSINESS ANALYSIS 8
-- Business Problem:
-- Calculate the daily number of views, add-to-carts, and
-- transactions.
--
-- Return:
-- activity_date
-- views
-- addtocarts
-- transactions
--
-- Sort chronologically.
-- ==========================================================

SELECT
    DATE(timestamp) AS activity_date,
    SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN event = 'addtocart' THEN 1 ELSE 0 END)
        AS addtocarts,
    SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
        AS transactions
FROM events
GROUP BY DATE(timestamp)
ORDER BY activity_date;


-- ==========================================================
-- BUSINESS ANALYSIS 9
-- Business Problem:
-- Calculate daily transaction conversion rate.
--
-- Formula:
-- transactions / views * 100
--
-- Include only days with at least 100 views.
-- ==========================================================

WITH DailyMetrics AS (
    SELECT
        DATE(timestamp) AS activity_date,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS views,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transactions
    FROM events
    GROUP BY DATE(timestamp)
)
SELECT
    activity_date,
    views,
    transactions,
    ROUND(
        100.0 * transactions / NULLIF(views, 0),
        2
    ) AS conversion_rate
FROM DailyMetrics
WHERE views >= 100
ORDER BY activity_date;


-- ==========================================================
-- BUSINESS ANALYSIS 10
-- Business Problem:
-- Identify visitors whose transaction count is above the
-- average transaction count across all visitors.
--
-- Return:
-- visitorid
-- transaction_count
-- average_transaction_count
--
-- Sort by transaction_count DESC.
-- ==========================================================

WITH VisitorTransactions AS (
    SELECT
        visitorid,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transaction_count
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    transaction_count,
    ROUND(
        AVG(transaction_count) OVER (),
        2
    ) AS average_transaction_count
FROM VisitorTransactions
WHERE transaction_count >
      (SELECT AVG(transaction_count)
       FROM VisitorTransactions)
ORDER BY transaction_count DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 11
-- Business Problem:
-- Find visitors who viewed many products but purchased
-- very few products.
--
-- Conditions:
-- 1. At least 10 distinct viewed products
-- 2. At most 1 distinct purchased product
--
-- Return:
-- visitorid
-- viewed_products
-- purchased_products
-- ==========================================================

SELECT
    visitorid,
    COUNT(DISTINCT CASE
        WHEN event = 'view' THEN itemid
    END) AS viewed_products,
    COUNT(DISTINCT CASE
        WHEN event = 'transaction' THEN itemid
    END) AS purchased_products
FROM events
GROUP BY visitorid
HAVING viewed_products >= 10
   AND purchased_products <= 1
ORDER BY viewed_products DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 12
-- Business Problem:
-- Find products with strong views and strong transactions
-- compared with the overall product averages.
--
-- Conditions:
-- 1. Views above average product views
-- 2. Transactions above average product transactions
--
-- Return:
-- itemid
-- views
-- transactions
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS views,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transactions
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    views,
    transactions
FROM ProductMetrics
WHERE views > (SELECT AVG(views) FROM ProductMetrics)
  AND transactions > (SELECT AVG(transactions) FROM ProductMetrics)
ORDER BY transactions DESC,
         views DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 13
-- Business Problem:
-- Find products that have properties and calculate their
-- business performance.
--
-- Return:
-- itemid
-- property_count
-- views
-- transactions
-- conversion_rate
--
-- Include only products with at least 3 properties and
-- at least 100 views.
-- ==========================================================

WITH ProductProperties AS (
    SELECT
        itemid,
        COUNT(DISTINCT property) AS property_count
    FROM properties
    GROUP BY itemid
),
ProductActivity AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS views,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transactions
    FROM events
    GROUP BY itemid
)
SELECT
    pp.itemid,
    pp.property_count,
    pa.views,
    pa.transactions,
    ROUND(
        100.0 * pa.transactions / NULLIF(pa.views, 0),
        2
    ) AS conversion_rate
FROM ProductProperties pp
INNER JOIN ProductActivity pa
    ON pp.itemid = pa.itemid
WHERE pp.property_count >= 3
  AND pa.views >= 100
ORDER BY conversion_rate DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 14
-- Business Problem:
-- Identify visitors who have a high transaction frequency
-- relative to their total activity.
--
-- Calculate:
-- transaction_rate = transactions / total_events * 100
--
-- Include visitors with at least 20 events.
-- Return the top 20 by transaction rate.
-- ==========================================================

WITH VisitorMetrics AS (
    SELECT
        visitorid,
        COUNT(*) AS total_events,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transactions
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    total_events,
    transactions,
    ROUND(
        100.0 * transactions / NULLIF(total_events, 0),
        2
    ) AS transaction_rate
FROM VisitorMetrics
WHERE total_events >= 20
ORDER BY transaction_rate DESC
LIMIT 20;


-- ==========================================================
-- BUSINESS ANALYSIS 15
-- Business Problem:
-- Identify products with unusually high transaction
-- conversion compared with other products.
--
-- Return:
-- itemid
-- views
-- transactions
-- conversion_rate
-- conversion_rank
--
-- Only consider products with at least 100 views.
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS views,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END)
            AS transactions
    FROM events
    GROUP BY itemid
),
ProductConversion AS (
    SELECT
        itemid,
        views,
        transactions,
        ROUND(
            100.0 * transactions / NULLIF(views, 0),
            2
        ) AS conversion_rate
    FROM ProductMetrics
    WHERE views >= 100
),
RankedProducts AS (
    SELECT
        itemid,
        views,
        transactions,
        conversion_rate,
        RANK() OVER (
            ORDER BY conversion_rate DESC
        ) AS conversion_rank
    FROM ProductConversion
)
SELECT
    itemid,
    views,
    transactions,
    conversion_rate,
    conversion_rank
FROM RankedProducts
ORDER BY conversion_rank;


-- ==========================================================
-- BUSINESS ANALYSIS 16
-- Business Problem:
-- Identify visitors who show a drop-off between viewing
-- products and purchasing them.
--
-- Calculate:
-- viewed_products
-- purchased_products
-- product_dropoff
--
-- product_dropoff =
-- viewed_products - purchased_products
--
-- Include visitors who viewed at least 10 distinct products.
-- Sort by product_dropoff DESC.
-- ==========================================================

WITH VisitorProducts AS (
    SELECT
        visitorid,
        COUNT(DISTINCT CASE
            WHEN event = 'view' THEN itemid
        END) AS viewed_products,
        COUNT(DISTINCT CASE
            WHEN event = 'transaction' THEN itemid
        END) AS purchased_products
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    viewed_products,
    purchased_products,
    viewed_products - purchased_products AS product_dropoff
FROM VisitorProducts
WHERE viewed_products >= 10
ORDER BY product_dropoff DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 17
-- Business Problem:
-- Management wants to identify the products responsible
-- for the majority of transactions.
--
-- Calculate:
-- itemid
-- transaction_count
-- percentage_of_transactions
-- cumulative_transaction_percentage
--
-- Sort by transaction_count DESC.
-- ==========================================================

WITH ProductTransactions AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS transaction_count
    FROM events
    GROUP BY itemid
),
TransactionShare AS (
    SELECT
        itemid,
        transaction_count,
        ROUND(
            100.0 * transaction_count /
            SUM(transaction_count) OVER (),
            2
        ) AS percentage_of_transactions,
        ROUND(
            100.0 *
            SUM(transaction_count) OVER (
                ORDER BY transaction_count DESC
                ROWS BETWEEN UNBOUNDED PRECEDING
                AND CURRENT ROW
            )
            / SUM(transaction_count) OVER (),
            2
        ) AS cumulative_transaction_percentage
    FROM ProductTransactions
)
SELECT
    itemid,
    transaction_count,
    percentage_of_transactions,
    cumulative_transaction_percentage
FROM TransactionShare
ORDER BY transaction_count DESC;


-- ==========================================================
-- BUSINESS ANALYSIS 18 - FINAL BUSINESS CASE
--
-- Business Problem:
-- Management wants a complete product performance report.
--
-- A product must have:
-- 1. At least 100 views
-- 2. At least 10 add-to-carts
-- 3. At least 1 transaction
--
-- Calculate:
-- 1. views
-- 2. addtocarts
-- 3. transactions
-- 4. view_to_addtocart_rate
-- 5. view_to_transaction_rate
-- 6. addtocart_to_transaction_rate
-- 7. performance_rank
--
-- Rank products by view-to-transaction conversion rate.
--
-- Sort by performance_rank.
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS views,
        SUM(CASE
            WHEN event = 'addtocart' THEN 1
            ELSE 0
        END) AS addtocarts,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS transactions
    FROM events
    GROUP BY itemid
),
ProductRates AS (
    SELECT
        itemid,
        views,
        addtocarts,
        transactions,

        ROUND(
            100.0 * addtocarts / NULLIF(views, 0),
            2
        ) AS view_to_addtocart_rate,

        ROUND(
            100.0 * transactions / NULLIF(views, 0),
            2
        ) AS view_to_transaction_rate,

        ROUND(
            100.0 * transactions / NULLIF(addtocarts, 0),
            2
        ) AS addtocart_to_transaction_rate

    FROM ProductMetrics
),
RankedProducts AS (
    SELECT
        itemid,
        views,
        addtocarts,
        transactions,
        view_to_addtocart_rate,
        view_to_transaction_rate,
        addtocart_to_transaction_rate,

        RANK() OVER (
            ORDER BY view_to_transaction_rate DESC
        ) AS performance_rank

    FROM ProductRates

    WHERE views >= 100
      AND addtocarts >= 10
      AND transactions >= 1
)
SELECT
    itemid,
    views,
    addtocarts,
    transactions,
    view_to_addtocart_rate,
    view_to_transaction_rate,
    addtocart_to_transaction_rate,
    performance_rank
FROM RankedProducts
ORDER BY performance_rank;