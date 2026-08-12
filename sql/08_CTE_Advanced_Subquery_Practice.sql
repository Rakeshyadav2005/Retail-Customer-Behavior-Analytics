USE retail_analytics;

-- ==========================================================
-- CTE & ADVANCED SUBQUERY PRACTICE
-- Total Problems: 12
-- ==========================================================


-- ==========================================================
-- CTE 1
-- Business Problem:
-- Identify visitors whose total number of events is greater
-- than the average number of events per visitor.
--
-- Return:
-- 1. visitorid
-- 2. total_events
--
-- Sort by total_events DESC.
-- ==========================================================

WITH VisitorEvents AS (
    SELECT
        visitorid,
        COUNT(*) AS total_events
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    total_events
FROM VisitorEvents
WHERE total_events > (
    SELECT AVG(total_events)
    FROM VisitorEvents
)
ORDER BY total_events DESC,
         visitorid ASC;


-- ==========================================================
-- CTE 2
-- Business Problem:
-- Identify products whose total views are greater than the
-- average number of views per product.
--
-- Return:
-- 1. itemid
-- 2. total_views
--
-- Sort by total_views DESC.
-- ==========================================================

WITH ProductViews AS (
    SELECT
        itemid,
        SUM(
            CASE
                WHEN event = 'view' THEN 1
                ELSE 0
            END
        ) AS total_views
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    total_views
FROM ProductViews
WHERE total_views > (
    SELECT AVG(total_views)
    FROM ProductViews
)
ORDER BY total_views DESC;


-- ==========================================================
-- CTE 3
-- Business Problem:
-- Find visitors who have viewed more products than the
-- average number of distinct products viewed by a visitor.
--
-- Return:
-- 1. visitorid
-- 2. distinct_products_viewed
--
-- Only count products associated with view events.
-- ==========================================================

WITH VisitorProducts AS (
    SELECT
        visitorid,
        COUNT(DISTINCT CASE
            WHEN event = 'view' THEN itemid
        END) AS distinct_products_viewed
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    distinct_products_viewed
FROM VisitorProducts
WHERE distinct_products_viewed > (
    SELECT AVG(distinct_products_viewed)
    FROM VisitorProducts
)
ORDER BY distinct_products_viewed DESC;


-- ==========================================================
-- CTE 4
-- Business Problem:
-- Calculate views, add-to-cart events, and transactions
-- for every product.
--
-- Return:
-- 1. itemid
-- 2. total_views
-- 3. total_addtocarts
-- 4. total_transactions
--
-- Include products with at least one transaction.
-- ==========================================================

WITH ProductActivity AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS total_views,
        SUM(CASE
            WHEN event = 'addtocart' THEN 1
            ELSE 0
        END) AS total_addtocarts,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS total_transactions
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    total_views,
    total_addtocarts,
    total_transactions
FROM ProductActivity
WHERE total_transactions > 0
ORDER BY total_transactions DESC;


-- ==========================================================
-- CTE 5
-- Business Problem:
-- Find products whose transaction count is greater than
-- the average transaction count across all products.
--
-- Return:
-- 1. itemid
-- 2. total_transactions
--
-- Sort by total_transactions DESC.
-- ==========================================================

WITH ProductTransactions AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS total_transactions
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    total_transactions
FROM ProductTransactions
WHERE total_transactions > (
    SELECT AVG(total_transactions)
    FROM ProductTransactions
)
ORDER BY total_transactions DESC;


-- ==========================================================
-- CTE 6
-- Business Problem:
-- Identify visitors who have both:
-- 1. More than 10 views
-- 2. At least 2 transactions
--
-- Return:
-- 1. visitorid
-- 2. total_views
-- 3. total_transactions
--
-- Sort by total_transactions DESC, total_views DESC.
-- ==========================================================

WITH VisitorActivity AS (
    SELECT
        visitorid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS total_views,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS total_transactions
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    total_views,
    total_transactions
FROM VisitorActivity
WHERE total_views > 10
  AND total_transactions >= 2
ORDER BY total_transactions DESC,
         total_views DESC;


-- ==========================================================
-- CTE 7
-- Business Problem:
-- Find products that have:
-- 1. At least 500 views
-- 2. At least 20 add-to-carts
-- 3. A transaction-to-view conversion rate above 5%
--
-- Return:
-- 1. itemid
-- 2. total_views
-- 3. total_addtocarts
-- 4. total_transactions
-- 5. conversion_rate
--
-- Conversion rate:
-- transactions / views * 100
-- ==========================================================

WITH ProductMetrics AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS total_views,
        SUM(CASE
            WHEN event = 'addtocart' THEN 1
            ELSE 0
        END) AS total_addtocarts,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS total_transactions
    FROM events
    GROUP BY itemid
),
ProductConversion AS (
    SELECT
        itemid,
        total_views,
        total_addtocarts,
        total_transactions,
        ROUND(
            100.0 * total_transactions / NULLIF(total_views, 0),
            2
        ) AS conversion_rate
    FROM ProductMetrics
)
SELECT
    itemid,
    total_views,
    total_addtocarts,
    total_transactions,
    conversion_rate
FROM ProductConversion
WHERE total_views >= 500
  AND total_addtocarts >= 20
  AND conversion_rate > 5
ORDER BY conversion_rate DESC;


-- ==========================================================
-- CTE 8
-- Business Problem:
-- Identify visitors who purchased products that have
-- property information.
--
-- Return:
-- 1. visitorid
-- 2. distinct_purchased_products
-- 3. distinct_products_with_properties
--
-- Use events and properties.
-- ==========================================================

WITH PurchasedProducts AS (
    SELECT DISTINCT
        visitorid,
        itemid
    FROM events
    WHERE event = 'transaction'
),
VisitorPropertyPurchases AS (
    SELECT
        pp.visitorid,
        COUNT(DISTINCT pp.itemid) AS distinct_purchased_products
    FROM PurchasedProducts pp
    INNER JOIN properties p
        ON pp.itemid = p.itemid
    GROUP BY pp.visitorid
)
SELECT
    visitorid,
    distinct_purchased_products
FROM VisitorPropertyPurchases
ORDER BY distinct_purchased_products DESC;


-- ==========================================================
-- CTE 9
-- Business Problem:
-- Find the property names associated with products that
-- generated more transactions than the average product.
--
-- Return:
-- 1. property
-- 2. number of products above average
--
-- Sort by number of products DESC.
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
AboveAverageProducts AS (
    SELECT
        itemid
    FROM ProductTransactions
    WHERE transaction_count > (
        SELECT AVG(transaction_count)
        FROM ProductTransactions
    )
)
SELECT
    p.property,
    COUNT(DISTINCT p.itemid) AS product_count
FROM properties p
INNER JOIN AboveAverageProducts a
    ON p.itemid = a.itemid
GROUP BY p.property
ORDER BY product_count DESC;


-- ==========================================================
-- CTE 10
-- Business Problem:
-- Find visitors whose latest activity happened after the
-- average latest activity timestamp.
--
-- Return:
-- 1. visitorid
-- 2. latest_activity
--
-- Sort by latest_activity DESC.
-- ==========================================================

WITH VisitorLastActivity AS (
    SELECT
        visitorid,
        MAX(timestamp) AS latest_activity
    FROM events
    GROUP BY visitorid
)
SELECT
    visitorid,
    latest_activity
FROM VisitorLastActivity
WHERE latest_activity > (
    SELECT AVG(latest_activity)
    FROM VisitorLastActivity
)
ORDER BY latest_activity DESC;


-- ==========================================================
-- CTE 11
-- Business Problem:
-- Identify visitors whose transaction count is greater than
-- the average transaction count among all visitors.
--
-- Return:
-- 1. visitorid
-- 2. transaction_count
-- 3. transaction_difference_from_average
--
-- Sort by transaction_count DESC.
-- ==========================================================

WITH VisitorTransactions AS (
    SELECT
        visitorid,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS transaction_count
    FROM events
    GROUP BY visitorid
),
AverageTransactions AS (
    SELECT
        AVG(transaction_count) AS average_transaction_count
    FROM VisitorTransactions
)
SELECT
    vt.visitorid,
    vt.transaction_count,
    ROUND(
        vt.transaction_count - at.average_transaction_count,
        2
    ) AS transaction_difference_from_average
FROM VisitorTransactions vt
CROSS JOIN AverageTransactions at
WHERE vt.transaction_count > at.average_transaction_count
ORDER BY vt.transaction_count DESC;


-- ==========================================================
-- CTE 12 - FINAL CTE BUSINESS CASE
-- Business Problem:
-- The business wants to identify high-performing products.
--
-- A product is considered high-performing if:
-- 1. Its views are above the average product views.
-- 2. Its transactions are above the average product
--    transactions.
-- 3. It has at least one property.
--
-- Return:
-- 1. itemid
-- 2. total_views
-- 3. total_transactions
-- 4. property_count
--
-- Sort by:
-- 1. total_transactions DESC
-- 2. total_views DESC
-- ==========================================================

WITH ProductActivity AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS total_views,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS total_transactions
    FROM events
    GROUP BY itemid
),
ProductProperties AS (
    SELECT
        itemid,
        COUNT(DISTINCT property) AS property_count
    FROM properties
    GROUP BY itemid
),
ProductMetrics AS (
    SELECT
        pa.itemid,
        pa.total_views,
        pa.total_transactions,
        pp.property_count
    FROM ProductActivity pa
    INNER JOIN ProductProperties pp
        ON pa.itemid = pp.itemid
),
Averages AS (
    SELECT
        AVG(total_views) AS avg_views,
        AVG(total_transactions) AS avg_transactions
    FROM ProductMetrics
)
SELECT
    pm.itemid,
    pm.total_views,
    pm.total_transactions,
    pm.property_count
FROM ProductMetrics pm
CROSS JOIN Averages a
WHERE pm.total_views > a.avg_views
  AND pm.total_transactions > a.avg_transactions
  AND pm.property_count > 0
ORDER BY pm.total_transactions DESC,
         pm.total_views DESC;