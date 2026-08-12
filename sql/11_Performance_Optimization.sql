USE retail_analytics;

-- ==========================================================
-- PERFORMANCE OPTIMIZATION PRACTICE
-- Total Problems: 8
-- ==========================================================


-- ==========================================================
-- PERFORMANCE 1
-- Business Problem:
-- The analytics team frequently searches events for a
-- particular visitor.
--
-- Create an index that improves queries filtering by
-- visitorid.
--
-- Then inspect the indexes on the events table.
-- ==========================================================

CREATE INDEX idx_events_visitorid
ON events(visitorid);

SHOW INDEX FROM events;


-- ==========================================================
-- PERFORMANCE 2
-- Business Problem:
-- Analysts frequently retrieve all events for a particular
-- product.
--
-- Create an index on itemid.
--
-- Then verify the index.
-- ==========================================================

CREATE INDEX idx_events_itemid
ON events(itemid);

SHOW INDEX FROM events;


-- ==========================================================
-- PERFORMANCE 3
-- Business Problem:
-- Analysts frequently filter events by event type and then
-- analyze a particular product.
--
-- Create a composite index using:
-- 1. event
-- 2. itemid
--
-- Then verify the index.
-- ==========================================================

CREATE INDEX idx_events_event_itemid
ON events(event, itemid);

SHOW INDEX FROM events;


-- ==========================================================
-- PERFORMANCE 4
-- Business Problem:
-- The following query is frequently used to find transaction
-- events for a particular product.
--
-- Analyze the query execution plan.
--
-- Do NOT modify the query.
-- Use EXPLAIN to inspect how MySQL plans to execute it.
-- ==========================================================

EXPLAIN
SELECT
    itemid,
    timestamp,
    visitorid,
    transactionid
FROM events
WHERE event = 'transaction'
  AND itemid = 12345;


-- ==========================================================
-- PERFORMANCE 5
-- Business Problem:
-- The analytics team needs the number of transactions for
-- every product.
--
-- Analyze the execution plan for this aggregation query.
--
-- Look at:
-- 1. type
-- 2. possible_keys
-- 3. key
-- 4. rows
-- 5. Extra
-- ==========================================================

EXPLAIN
SELECT
    itemid,
    COUNT(*) AS transaction_count
FROM events
WHERE event = 'transaction'
GROUP BY itemid;


-- ==========================================================
-- PERFORMANCE 6
-- Business Problem:
-- Analysts frequently retrieve events for a visitor within
-- a specific time period.
--
-- Create a composite index that supports filtering by:
-- 1. visitorid
-- 2. timestamp
--
-- Then verify the index.
-- ==========================================================

CREATE INDEX idx_events_visitor_timestamp
ON events(visitorid, timestamp);

SHOW INDEX FROM events;


-- ==========================================================
-- PERFORMANCE 7
-- Business Problem:
-- The team wants to compare the execution plan of a query
-- before and after indexing.
--
-- Analyze this query using EXPLAIN.
--
-- The query retrieves transaction events for a visitor.
-- ==========================================================

EXPLAIN
SELECT
    timestamp,
    itemid,
    transactionid
FROM events
WHERE visitorid = 123456
  AND event = 'transaction'
ORDER BY timestamp;


-- ==========================================================
-- PERFORMANCE 8 - FINAL OPTIMIZATION CASE
--
-- Business Problem:
-- The reporting team frequently runs this query to identify
-- products with more than 100 transactions.
--
-- Step 1:
-- Inspect the execution plan.
--
-- Step 2:
-- Create an appropriate index to improve filtering by event
-- and grouping by itemid.
--
-- Step 3:
-- Inspect the execution plan again.
--
-- Step 4:
-- Compare the EXPLAIN output before and after indexing.
-- ==========================================================

-- STEP 1: BEFORE INDEX

EXPLAIN
SELECT
    itemid,
    COUNT(*) AS transaction_count
FROM events
WHERE event = 'transaction'
GROUP BY itemid
HAVING transaction_count > 100;


-- STEP 2: INDEX

CREATE INDEX idx_events_event_itemid_optimization
ON events(event, itemid);


-- STEP 3: AFTER INDEX

EXPLAIN
SELECT
    itemid,
    COUNT(*) AS transaction_count
FROM events
WHERE event = 'transaction'
GROUP BY itemid
HAVING transaction_count > 100;