-- =====================================================
-- Database Verification
-- =====================================================

-- Select Database
USE retail_analytics;

-- Verify Available Tables
SHOW TABLES;

-- Verify Table Structures
DESCRIBE events;
DESCRIBE categories;
DESCRIBE properties;

-- verify the data
SELECT COUNT(*) as TOTAL_CATEGORIES FROM categories;
SELECT COUNT(*) AS TOTAL_EVENTS FROM events;
SELECT COUNT(*) AS TOTAL_PROPERTIES FROM properties;
-- Verify null values
SELECT 
	SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END) as TotalNullTimestamps,
    SUM(CASE WHEN visitorid IS NULL THEN 1 ELSE 0 END) as NullVisitorId,
	SUM(CASE WHEN event IS NULL THEN 1 ELSE 0 END) as NullEvent,
    SUM(CASE WHEN itemid IS NULL THEN 1 ELSE 0 END) as NullItemId,
	SUM(CASE WHEN transactionid IS NULL THEN 1 ELSE 0 END) as NullTransactionId 
FROM events;
-- Another way to count Null values
SELECT 
	COUNT(*)-COUNT(categoryid) AS NUllCategotyIds,
	COUNT(*)-COUNT(parentid) AS NullParentId
FROM categories;

SELECT 
	SUM(CASE WHEN timestamp IS NULL THEN 1 ELSE 0 END) as TotalNullTimestamps,
    SUM(CASE WHEN itemid IS NULL THEN 1 ELSE 0 END) AS NullItemId,
    SUM(CASE WHEN property IS NULL THEN 1 ELSE 0 END) AS NullPropertyId,
    SUM(CASE WHEN value IS NULL THEN 1 ELSE 0 END) AS NullValueId
FROM properties;

-- Duplicate check
SELECT COUNT(*) AS TOTALDUPLICATEGROUPS FROM (SELECT timestamp,
    visitorid,
    event,
    itemid,
    transactionid,
    COUNT(*) AS DuplicateCount
FROM events
GROUP BY 
	timestamp,
    visitorid,
    event,
    itemid,
    transactionid
HAVING
	COUNT(*)>1) AS T;


-- Verify duplicate groups in properties

/*
Duplicate verification for the properties table was skipped.

Reason:
The properties table contains over 20 million rows.
A GROUP BY on all columns is computationally expensive
without indexes and may cause timeout in MySQL Workbench.

Since row counts, NULL checks, and import validation
were successful, duplicate verification will be discussed
later in the Indexes and Performance Optimization section.
*/
    
-- Verify duplicate groups in categories

SELECT
    COUNT(*) AS CategoryDuplicateGroups
FROM
(
    SELECT
        categoryid,
        parentid
    FROM categories
    GROUP BY
        categoryid,
        parentid
    HAVING COUNT(*) > 1
) AS CategoryDuplicates;

-- Verify categoryid uniqueness

SELECT
    categoryid,
    COUNT(*) AS DuplicateCount
FROM categories
GROUP BY categoryid
HAVING COUNT(*) > 1;

-- Verify event values

SELECT
    event,
    COUNT(*) AS TotalEvents
FROM events
GROUP BY event;