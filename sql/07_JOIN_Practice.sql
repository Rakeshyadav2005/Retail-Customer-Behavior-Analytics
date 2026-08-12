USE retail_analytics;

-- ==========================================================
-- JOIN PRACTICE
-- Total Problems: 18
-- ==========================================================


-- ==========================================================
-- JOIN 1
-- Business Problem:
-- Find products that appear in BOTH events and properties.
--
-- Return:
-- 1. itemid
--
-- Use INNER JOIN.
-- ==========================================================

SELECT DISTINCT
    e.itemid
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid;


-- ==========================================================
-- JOIN 2
-- Business Problem:
-- Find all event records that have a matching property record.
--
-- Return:
-- 1. visitorid
-- 2. event
-- 3. itemid
-- 4. property
-- 5. value
--
-- Sort by itemid.
-- ==========================================================

SELECT
    e.visitorid,
    e.event,
    e.itemid,
    p.property,
    p.value
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
ORDER BY e.itemid;


-- ==========================================================
-- JOIN 3
-- Business Problem:
-- Find products that have property information but have
-- never appeared in the events table.
--
-- Return:
-- 1. itemid
--
-- Use LEFT JOIN starting from properties.
-- ==========================================================

SELECT DISTINCT
    p.itemid
FROM properties p
LEFT JOIN events e
    ON p.itemid = e.itemid
WHERE e.itemid IS NULL;


-- ==========================================================
-- JOIN 4
-- Business Problem:
-- Find products that appear in events but do NOT have
-- any property information.
--
-- Return:
-- 1. itemid
--
-- Use LEFT JOIN.
-- ==========================================================

SELECT DISTINCT
    e.itemid
FROM events e
LEFT JOIN properties p
    ON e.itemid = p.itemid
WHERE p.itemid IS NULL;


-- ==========================================================
-- JOIN 5
-- Business Problem:
-- For each product, find how many different properties
-- are available.
--
-- Return:
-- 1. itemid
-- 2. Number of distinct properties
--
-- Include only products that have at least 2 properties.
-- ==========================================================

SELECT
    p.itemid,
    COUNT(DISTINCT p.property) AS property_count
FROM properties p
GROUP BY p.itemid
HAVING property_count >= 2
ORDER BY property_count DESC;


-- ==========================================================
-- JOIN 6
-- Business Problem:
-- Find products that have been viewed and also have
-- at least one property.
--
-- Return:
-- 1. itemid
-- 2. Total views
--
-- Only include products with at least one view.
-- ==========================================================

SELECT
    e.itemid,
    SUM(
        CASE
            WHEN e.event = 'view' THEN 1
            ELSE 0
        END
    ) AS total_views
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
GROUP BY e.itemid
HAVING total_views > 0
ORDER BY total_views DESC;


-- ==========================================================
-- JOIN 7
-- Business Problem:
-- Find the number of products associated with each
-- property name.
--
-- Return:
-- 1. property
-- 2. Number of distinct products
--
-- Sort by product count DESC.
-- ==========================================================

SELECT
    p.property,
    COUNT(DISTINCT p.itemid) AS product_count
FROM properties p
GROUP BY p.property
ORDER BY product_count DESC;


-- ==========================================================
-- JOIN 8
-- Business Problem:
-- Find products that have BOTH:
-- 1. At least one transaction
-- 2. At least one property
--
-- Return:
-- 1. itemid
-- 2. Transaction count
-- ==========================================================

SELECT
    e.itemid,
    SUM(
        CASE
            WHEN e.event = 'transaction' THEN 1
            ELSE 0
        END
    ) AS transaction_count
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
GROUP BY e.itemid
HAVING transaction_count > 0
ORDER BY transaction_count DESC;


-- ==========================================================
-- JOIN 9
-- Business Problem:
-- Find all event types associated with products that have
-- property information.
--
-- Return:
-- 1. event
-- 2. Number of distinct products
--
-- Sort by product count DESC.
-- ==========================================================

SELECT
    e.event,
    COUNT(DISTINCT e.itemid) AS product_count
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
GROUP BY e.event
ORDER BY product_count DESC;


-- ==========================================================
-- JOIN 10
-- Business Problem:
-- Find products with property information and calculate
-- their total number of events.
--
-- Return:
-- 1. itemid
-- 2. Total events
--
-- Important:
-- Avoid duplicate counting caused by multiple property
-- records for the same product.
-- ==========================================================

SELECT
    e.itemid,
    COUNT(*) AS total_events
FROM events e
WHERE EXISTS (
    SELECT 1
    FROM properties p
    WHERE p.itemid = e.itemid
)
GROUP BY e.itemid
ORDER BY total_events DESC;


-- ==========================================================
-- JOIN 11
-- Business Problem:
-- Find the properties associated with products that have
-- at least one transaction.
--
-- Return:
-- 1. property
-- 2. Number of distinct purchased products
--
-- Sort by purchased product count DESC.
-- ==========================================================

SELECT
    p.property,
    COUNT(DISTINCT p.itemid) AS purchased_products
FROM properties p
INNER JOIN (
    SELECT DISTINCT
        itemid
    FROM events
    WHERE event = 'transaction'
) t
    ON p.itemid = t.itemid
GROUP BY p.property
ORDER BY purchased_products DESC;


-- ==========================================================
-- JOIN 12
-- Business Problem:
-- Find products that have been viewed but never purchased,
-- and also have property information.
--
-- Return:
-- 1. itemid
-- 2. View count
--
-- Sort by view count DESC.
-- ==========================================================

SELECT
    e.itemid,
    SUM(
        CASE
            WHEN e.event = 'view' THEN 1
            ELSE 0
        END
    ) AS view_count
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
GROUP BY e.itemid
HAVING view_count > 0
   AND SUM(
        CASE
            WHEN e.event = 'transaction' THEN 1
            ELSE 0
        END
   ) = 0
ORDER BY view_count DESC;


-- ==========================================================
-- JOIN 13
-- Business Problem:
-- Find the most common property for products that have
-- received transactions.
--
-- Return:
-- 1. property
-- 2. Number of distinct purchased products
--
-- Sort by purchased product count DESC.
-- ==========================================================

SELECT
    p.property,
    COUNT(DISTINCT p.itemid) AS purchased_product_count
FROM properties p
INNER JOIN events e
    ON p.itemid = e.itemid
WHERE e.event = 'transaction'
GROUP BY p.property
ORDER BY purchased_product_count DESC;


-- ==========================================================
-- JOIN 14
-- Business Problem:
-- Find products that have multiple properties AND have
-- received at least one transaction.
--
-- Return:
-- 1. itemid
-- 2. Number of properties
-- 3. Number of transactions
--
-- Include products with:
-- - At least 2 distinct properties
-- - At least 1 transaction
-- ==========================================================

SELECT
    p.itemid,
    COUNT(DISTINCT p.property) AS property_count,
    (
        SELECT COUNT(*)
        FROM events e2
        WHERE e2.itemid = p.itemid
          AND e2.event = 'transaction'
    ) AS transaction_count
FROM properties p
GROUP BY p.itemid
HAVING property_count >= 2
   AND transaction_count > 0
ORDER BY transaction_count DESC;


-- ==========================================================
-- JOIN 15
-- Business Problem:
-- Find the properties associated with products that have
-- more than 100 views.
--
-- Return:
-- 1. property
-- 2. Number of distinct products
--
-- Sort by product count DESC.
-- ==========================================================

SELECT
    p.property,
    COUNT(DISTINCT p.itemid) AS product_count
FROM properties p
INNER JOIN (
    SELECT
        itemid
    FROM events
    WHERE event = 'view'
    GROUP BY itemid
    HAVING COUNT(*) > 100
) v
    ON p.itemid = v.itemid
GROUP BY p.property
ORDER BY product_count DESC;


-- ==========================================================
-- JOIN 16
-- Business Problem:
-- Compare products that have property information with
-- products that do not have property information.
--
-- Return:
-- 1. Property status
-- 2. Number of distinct products
--
-- Property status should be:
-- 'Has Property'
-- 'No Property'
-- ==========================================================

SELECT
    CASE
        WHEN p.itemid IS NULL THEN 'No Property'
        ELSE 'Has Property'
    END AS property_status,
    COUNT(DISTINCT e.itemid) AS product_count
FROM events e
LEFT JOIN properties p
    ON e.itemid = p.itemid
GROUP BY property_status;


-- ==========================================================
-- JOIN 17
-- Business Problem:
-- Find visitors who interacted with products that have
-- property information.
--
-- Return:
-- 1. visitorid
-- 2. Number of distinct products with properties
--
-- Sort by product count DESC.
-- ==========================================================

SELECT
    e.visitorid,
    COUNT(DISTINCT e.itemid) AS products_with_properties
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
GROUP BY e.visitorid
ORDER BY products_with_properties DESC;


-- ==========================================================
-- JOIN 18
-- Business Problem:
-- Find visitors who purchased products that have property
-- information.
--
-- Return:
-- 1. visitorid
-- 2. Number of distinct purchased products with properties
--
-- Sort by purchased product count DESC.
-- ==========================================================

SELECT
    e.visitorid,
    COUNT(DISTINCT e.itemid) AS purchased_products_with_properties
FROM events e
INNER JOIN properties p
    ON e.itemid = p.itemid
WHERE e.event = 'transaction'
GROUP BY e.visitorid
ORDER BY purchased_products_with_properties DESC;