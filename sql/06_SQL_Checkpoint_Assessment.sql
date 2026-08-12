-- ==========================================================
-- Assessment 1
-- Business Problem:
-- Find products that have more than 1000 view events.
--
-- Return:
-- 1. itemid
-- 2. Total view events
--
-- Sort by:
-- 1. View count DESC
-- 2. itemid ASC
-- ==========================================================
SELECT itemid,sum(CASE WHEN event='view' THEN 1 ELSE 0 END) as view_count
FROM events
GROUP BY itemid
HAVING view_count>1000
ORDER BY view_count DESC,itemid ASC;

-- =============================================================================
-- Assessment Question 2
-- =============================================================================
-- Business Problem:
-- The Sales Team wants to identify repeat buyers.
--
-- Requirements:
-- 1. Return:
--      - visitorid
--      - Total number of transaction events
--      - Total number of distinct products purchased
--
-- 2. Include only visitors who:
--      - Made more than 2 transaction events.
--      - Purchased more than 2 distinct products.
--
-- 3. Important:
--      - Count distinct products ONLY from 'transaction' events.
--      - Ignore 'view' and 'addtocart' events while counting products purchased.
--
-- 4. Sort the result by:
--      - Transaction count DESC
--      - Distinct products purchased DESC
-- =============================================================================
SELECT visitorid,
SUM(CASE WHEN EVENT='TRANSACTION' THEN 1 ELSE 0 END) AS no_of_transaction,
COUNT(
    DISTINCT
    CASE
        WHEN event = 'transaction' THEN itemid
    END
) AS no_of_products
FROM EVENTS
GROUP BY visitorid
HAVING no_of_transaction>2 AND no_of_products>2
ORDER BY no_of_transaction DESC,no_of_products DESC;

-- =============================================================================
-- Assessment Question 3
-- =============================================================================
-- Business Problem:
-- The Product Team wants to identify products that are frequently added
-- to the cart but never purchased.
--
-- Requirements:
-- 1. Return:
--      - itemid
--      - Total add-to-cart events
--      - Total transaction events
--
-- 2. Include only products that:
--      - Have at least 10 add-to-cart events.
--      - Have 0 transaction events.
--
-- 3. Sort the result by:
--      - Add-to-cart events DESC
--      - itemid ASC
-- =============================================================================
SELECT 
	itemid,
    SUM(CASE WHEN event='addtocart' THEN 1 ELSE 0 END)AS Total_addtocart,
	SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END)AS Total_transaction
FROM EVENTS
GROUP BY itemid
HAVING
	Total_addtocart>=10 AND
    Total_transaction=0
ORDER BY 
	Total_addtocart DESC,
    itemid;

-- ==========================================================
-- Business Problem:
-- The Sales Team wants to identify repeat buyers.
--
-- Return:
-- 1. visitorid
-- 2. Total transaction events
-- 3. Total distinct products purchased
--
-- Include only visitors who:
-- - Made more than 2 transaction events
-- - Purchased more than 2 distinct products
--
-- Sort by:
-- 1. Transaction count DESC
-- 2. Distinct products purchased DESC
-- ==========================================================

SELECT
    visitorid,
    SUM(CASE
        WHEN event = 'transaction' THEN 1
        ELSE 0
    END) AS Total_transactions,
    COUNT(DISTINCT CASE
        WHEN event = 'transaction' THEN itemid
    END) AS Distinct_products
FROM events
GROUP BY visitorid
HAVING Total_transactions > 2
   AND Distinct_products > 2
ORDER BY
    Total_transactions DESC,
    Distinct_products DESC;

-- ==========================================================
-- Assessment 3
-- Business Problem:
-- Identify visitors who were active on more than 5
-- different dates.
--
-- Return:
-- 1. visitorid
-- 2. Number of distinct active dates
--
-- Sort by:
-- 1. Active dates DESC
-- 2. visitorid ASC
-- ==========================================================

SELECT
    visitorid,
    COUNT(DISTINCT DATE(timestamp)) AS active_dates
FROM events
GROUP BY visitorid
HAVING active_dates > 5
ORDER BY active_dates DESC,
         visitorid ASC;

-- ==========================================================
-- Assessment 4
-- Business Problem:
-- Identify visitors who performed both an add-to-cart
-- event and a transaction event.
--
-- Return:
-- 1. visitorid
-- 2. Number of add-to-cart events
-- 3. Number of transaction events
--
-- Include visitors who performed at least one of each.
--
-- Sort by transaction count DESC.
-- ==========================================================

SELECT
    visitorid,
    SUM(CASE
        WHEN event = 'addtocart' THEN 1
        ELSE 0
    END) AS addtocart_count,
    SUM(CASE
        WHEN event = 'transaction' THEN 1
        ELSE 0
    END) AS transaction_count
FROM events
GROUP BY visitorid
HAVING addtocart_count > 0
   AND transaction_count > 0
ORDER BY transaction_count DESC;

-- ==========================================================
-- Assessment 5
-- Business Problem:
-- The analytics team wants to identify products where
-- transactions represent more than 5% of all events
-- recorded for that product.
--
-- Return:
-- 1. itemid
-- 2. Total events
-- 3. Total transactions
-- 4. Transaction percentage
--
-- Include products with transaction percentage > 5%.
--
-- Sort by transaction percentage DESC.
-- ==========================================================

SELECT
    itemid,
    COUNT(*) AS total_events,
    SUM(CASE
        WHEN event = 'transaction' THEN 1
        ELSE 0
    END) AS transaction_count,
    ROUND(
        100.0 * SUM(CASE
            WHEN event = 'transaction' THEN 1
            ELSE 0
        END) / COUNT(*),
        2
    ) AS transaction_percentage
FROM events
GROUP BY itemid
HAVING transaction_percentage > 5
ORDER BY transaction_percentage DESC;

-- ==========================================================
-- Assessment 6
-- Business Problem:
-- The customer success team wants to identify visitors
-- whose most recent activity occurred after a specified
-- timestamp.
--
-- Return:
-- 1. visitorid
-- 2. Most recent activity timestamp
--
-- Include visitors whose latest activity occurred after
-- '2015-09-01 00:00:00'.
--
-- Sort by latest activity DESC.
-- ==========================================================

SELECT
    visitorid,
    MAX(timestamp) AS latest_activity
FROM events
GROUP BY visitorid
HAVING latest_activity > '2015-09-01 00:00:00'
ORDER BY latest_activity DESC;

-- ==========================================================
-- Assessment 7
-- Business Problem:
-- The product team wants to find products that have
-- experienced all three major customer interaction types:
--
-- 1. View
-- 2. Add-to-cart
-- 3. Transaction
--
-- Return:
-- 1. itemid
-- 2. Number of different event types
--
-- Include only products that have all 3 event types.
--
-- Sort by itemid ASC.
-- ==========================================================

SELECT
    itemid,
    COUNT(DISTINCT event) AS event_type_count
FROM events
GROUP BY itemid
HAVING event_type_count = 3
ORDER BY itemid ASC;

-- ==========================================================
-- Assessment 8
-- Business Problem:
-- The marketing team wants to identify visitors who have
-- more add-to-cart events than transaction events.
--
-- Return:
-- 1. visitorid
-- 2. Add-to-cart count
-- 3. Transaction count
-- 4. Difference between add-to-cart and transaction count
--
-- Include visitors where:
-- Add-to-cart count > Transaction count
--
-- Sort by the difference DESC.
-- ==========================================================

SELECT
    visitorid,
    SUM(CASE
        WHEN event = 'addtocart' THEN 1
        ELSE 0
    END) AS addtocart_count,
    SUM(CASE
        WHEN event = 'transaction' THEN 1
        ELSE 0
    END) AS transaction_count,
    SUM(CASE
        WHEN event = 'addtocart' THEN 1
        ELSE 0
    END)
    -
    SUM(CASE
        WHEN event = 'transaction' THEN 1
        ELSE 0
    END) AS engagement_gap
FROM events
GROUP BY visitorid
HAVING engagement_gap > 0
ORDER BY engagement_gap DESC;

-- ==========================================================
-- Assessment 9
-- Business Problem:
-- The finance team wants to identify products that were
-- purchased exactly once but received at least 100 views.
--
-- Return:
-- 1. itemid
-- 2. View count
-- 3. Transaction count
--
-- Conditions:
-- View count >= 100
-- Transaction count = 1
--
-- Sort by view count DESC.
-- ==========================================================

SELECT
    itemid,
    SUM(CASE
        WHEN event = 'view' THEN 1
        ELSE 0
    END) AS view_count,
    SUM(CASE
        WHEN event = 'transaction' THEN 1
        ELSE 0
    END) AS transaction_count
FROM events
GROUP BY itemid
HAVING view_count >= 100
   AND transaction_count = 1
ORDER BY view_count DESC;

-- ==========================================================
-- Assessment 10
-- Business Problem:
-- The management team wants to understand how the entire
-- customer activity is distributed across event types.
--
-- Return:
-- 1. event
-- 2. Number of events
-- 3. Percentage of total events
--
-- Sort by number of events DESC.
-- ==========================================================

SELECT
    event,
    COUNT(*) AS event_count,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*) FROM events),
        2
    ) AS event_percentage
FROM events
GROUP BY event
ORDER BY event_count DESC;
