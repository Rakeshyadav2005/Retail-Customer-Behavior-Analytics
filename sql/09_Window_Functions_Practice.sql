USE retail_analytics;

-- ==========================================================
-- WINDOW FUNCTIONS PRACTICE
-- Total Problems: 18
-- ==========================================================


-- ==========================================================
-- WINDOW 1
-- Business Problem:
-- For every visitor, show their total number of events
-- and the overall average events per visitor.
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. average_events_per_visitor
--
-- Use a window function for the average.
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
    total_events,
    ROUND(AVG(total_events) OVER (), 2) AS average_events_per_visitor
FROM VisitorEvents
ORDER BY total_events DESC,
         visitorid ASC;


-- ==========================================================
-- WINDOW 2
-- Business Problem:
-- Rank visitors based on their total number of events.
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. visitor_rank
--
-- Highest event count should receive rank 1.
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
    total_events,
    RANK() OVER (
        ORDER BY total_events DESC
    ) AS visitor_rank
FROM VisitorEvents
ORDER BY visitor_rank;


-- ==========================================================
-- WINDOW 3
-- Business Problem:
-- Rank products based on their total number of views.
--
-- Return:
-- 1. itemid
-- 2. total_views
-- 3. product_rank
--
-- Use DENSE_RANK().
-- ==========================================================

WITH ProductViews AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS total_views
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    total_views,
    DENSE_RANK() OVER (
        ORDER BY total_views DESC
    ) AS product_rank
FROM ProductViews
ORDER BY product_rank;


-- ==========================================================
-- WINDOW 4
-- Business Problem:
-- Identify the top 3 most-viewed products.
--
-- Return:
-- 1. itemid
-- 2. total_views
-- 3. view_rank
--
-- Use ROW_NUMBER().
-- ==========================================================

WITH ProductViews AS (
    SELECT
        itemid,
        SUM(CASE
            WHEN event = 'view' THEN 1
            ELSE 0
        END) AS total_views
    FROM events
    GROUP BY itemid
),
RankedProducts AS (
    SELECT
        itemid,
        total_views,
        ROW_NUMBER() OVER (
            ORDER BY total_views DESC
        ) AS row_num
    FROM ProductViews
)
SELECT
    itemid,
    total_views,
    row_num AS view_rank
FROM RankedProducts
WHERE row_num <= 3
ORDER BY view_rank;


-- ==========================================================
-- WINDOW 5
-- Business Problem:
-- Find the most viewed product for each event category:
-- view, addtocart, and transaction.
--
-- Return:
-- 1. event
-- 2. itemid
-- 3. event_count
-- 4. rank_within_event
--
-- Rank products separately for each event type.
-- ==========================================================

WITH ProductEvents AS (
    SELECT
        event,
        itemid,
        COUNT(*) AS event_count
    FROM events
    GROUP BY event, itemid
),
RankedEvents AS (
    SELECT
        event,
        itemid,
        event_count,
        ROW_NUMBER() OVER (
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
FROM RankedEvents
WHERE rank_within_event = 1
ORDER BY event;


-- ==========================================================
-- WINDOW 6
-- Business Problem:
-- For each visitor, rank their products based on the number
-- of events they generated for that product.
--
-- Return:
-- 1. visitorid
-- 2. itemid
-- 3. event_count
-- 4. product_rank
--
-- Rank separately for every visitor.
-- ==========================================================

WITH VisitorProducts AS (
    SELECT
        visitorid,
        itemid,
        COUNT(*) AS event_count
    FROM events
    GROUP BY visitorid, itemid
)
SELECT
    visitorid,
    itemid,
    event_count,
    ROW_NUMBER() OVER (
        PARTITION BY visitorid
        ORDER BY event_count DESC
    ) AS product_rank
FROM VisitorProducts
ORDER BY visitorid,
         product_rank;


-- ==========================================================
-- WINDOW 7
-- Business Problem:
-- Calculate the running total of transactions ordered by
-- timestamp.
--
-- Return:
-- 1. timestamp
-- 2. transaction_event
-- 3. running_transactions
--
-- Each transaction event contributes 1.
-- ==========================================================

SELECT
    timestamp,
    1 AS transaction_event,
    SUM(1) OVER (
        ORDER BY timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_transactions
FROM events
WHERE event = 'transaction'
ORDER BY timestamp;


-- ==========================================================
-- WINDOW 8
-- Business Problem:
-- For each visitor, show their event count and the event
-- count of the previous visitor when visitors are ordered
-- by total events descending.
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. previous_visitor_events
--
-- Use LAG().
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
    total_events,
    LAG(total_events) OVER (
        ORDER BY total_events DESC
    ) AS previous_visitor_events
FROM VisitorEvents
ORDER BY total_events DESC;


-- ==========================================================
-- WINDOW 9
-- Business Problem:
-- For each visitor, show their event count and the event
-- count of the next visitor when visitors are ordered by
-- total events descending.
--
-- Use LEAD().
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
    total_events,
    LEAD(total_events) OVER (
        ORDER BY total_events DESC
    ) AS next_visitor_events
FROM VisitorEvents
ORDER BY total_events DESC;


-- ==========================================================
-- WINDOW 10
-- Business Problem:
-- Calculate the percentage contribution of each visitor
-- to the total number of events.
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. percentage_of_all_events
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
    total_events,
    ROUND(
        100.0 * total_events /
        SUM(total_events) OVER (),
        2
    ) AS percentage_of_all_events
FROM VisitorEvents
ORDER BY total_events DESC;


-- ==========================================================
-- WINDOW 11
-- Business Problem:
-- For each product, calculate the percentage of its events
-- that are transactions.
--
-- Return:
-- 1. itemid
-- 2. total_events
-- 3. transactions
-- 4. transaction_percentage
--
-- Use a window function to calculate the total event count
-- across products.
-- ==========================================================

WITH ProductTransactions AS (
    SELECT
        itemid,
        COUNT(*) AS total_events,
        SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) AS transactions
    FROM events
    GROUP BY itemid
)
SELECT
    itemid,
    total_events,
    transactions,
    ROUND(
        100.0 * transactions /
        SUM(transactions) OVER (),
        2
    ) AS transaction_percentage_of_all_transactions
FROM ProductTransactions
ORDER BY transactions DESC;


-- ==========================================================
-- WINDOW 12
-- Business Problem:
-- For each visitor, calculate their cumulative number of
-- events based on visitor ranking by total events.
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. cumulative_events
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
    total_events,
    SUM(total_events) OVER (
        ORDER BY total_events DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_events
FROM VisitorEvents
ORDER BY total_events DESC;


-- ==========================================================
-- WINDOW 13
-- Business Problem:
-- Find the top 3 products by transaction count within each
-- event category.
--
-- Return:
-- 1. event
-- 2. itemid
-- 3. event_count
-- 4. rank
--
-- Use PARTITION BY event.
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
        ) AS product_rank
    FROM ProductEvents
)
SELECT
    event,
    itemid,
    event_count,
    product_rank
FROM RankedProducts
WHERE product_rank <= 3
ORDER BY event,
         product_rank;


-- ==========================================================
-- WINDOW 14
-- Business Problem:
-- Compare each visitor's event count with the average event
-- count of all visitors.
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. average_events
-- 4. difference_from_average
--
-- Sort by difference_from_average DESC.
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
    total_events,
    ROUND(
        AVG(total_events) OVER (),
        2
    ) AS average_events,
    ROUND(
        total_events - AVG(total_events) OVER (),
        2
    ) AS difference_from_average
FROM VisitorEvents
ORDER BY difference_from_average DESC;


-- ==========================================================
-- WINDOW 15
-- Business Problem:
-- For each visitor, compare their current product's event
-- count with their previous product's event count.
--
-- Return:
-- 1. visitorid
-- 2. itemid
-- 3. event_count
-- 4. previous_product_event_count
-- 5. difference_from_previous
--
-- Order products by event count descending within visitor.
-- ==========================================================

WITH VisitorProducts AS (
    SELECT
        visitorid,
        itemid,
        COUNT(*) AS event_count
    FROM events
    GROUP BY visitorid, itemid
),
PreviousProduct AS (
    SELECT
        visitorid,
        itemid,
        event_count,
        LAG(event_count) OVER (
            PARTITION BY visitorid
            ORDER BY event_count DESC
        ) AS previous_product_event_count
    FROM VisitorProducts
)
SELECT
    visitorid,
    itemid,
    event_count,
    previous_product_event_count,
    event_count - previous_product_event_count
        AS difference_from_previous
FROM PreviousProduct
ORDER BY visitorid,
         event_count DESC;


-- ==========================================================
-- WINDOW 16
-- Business Problem:
-- Find the first and last product interacted with by each
-- visitor based on timestamp.
--
-- Return:
-- 1. visitorid
-- 2. first_item
-- 3. last_item
--
-- Use FIRST_VALUE() and LAST_VALUE().
-- ==========================================================

SELECT DISTINCT
    visitorid,
    FIRST_VALUE(itemid) OVER (
        PARTITION BY visitorid
        ORDER BY timestamp
    ) AS first_item,
    LAST_VALUE(itemid) OVER (
        PARTITION BY visitorid
        ORDER BY timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_item
FROM events
ORDER BY visitorid;


-- ==========================================================
-- WINDOW 17
-- Business Problem:
-- Divide visitors into 4 groups based on their total number
-- of events.
--
-- Group 1 = lowest activity
-- Group 4 = highest activity
--
-- Return:
-- 1. visitorid
-- 2. total_events
-- 3. activity_quartile
--
-- Use NTILE(4).
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
    total_events,
    NTILE(4) OVER (
        ORDER BY total_events
    ) AS activity_quartile
FROM VisitorEvents
ORDER BY activity_quartile,
         total_events;


-- ==========================================================
-- WINDOW 18 - FINAL BUSINESS CASE
--
-- Business Problem:
-- The business wants to identify the most important products.
--
-- For every product calculate:
-- 1. Views
-- 2. Add-to-carts
-- 3. Transactions
-- 4. Transaction conversion rate
-- 5. Rank by conversion rate
-- 6. Rank by transaction count
--
-- Return only the top 10 products by conversion rate.
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
            100.0 * total_transactions /
            NULLIF(total_views, 0),
            2
        ) AS conversion_rate
    FROM ProductMetrics
),
RankedProducts AS (
    SELECT
        itemid,
        total_views,
        total_addtocarts,
        total_transactions,
        conversion_rate,
        RANK() OVER (
            ORDER BY conversion_rate DESC
        ) AS conversion_rank,
        RANK() OVER (
            ORDER BY total_transactions DESC
        ) AS transaction_rank
    FROM ProductConversion
)
SELECT
    itemid,
    total_views,
    total_addtocarts,
    total_transactions,
    conversion_rate,
    conversion_rank,
    transaction_rank
FROM RankedProducts
WHERE conversion_rank <= 10
ORDER BY conversion_rank;