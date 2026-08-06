SELECT DISTINCT event FROM events;

SELECT COUNT(distinct event) AS TotalEventTypes FROM events;

SELECT *
FROM events
WHERE event='addtocart';

SELECT visitorid,itemid,transactionid FROM events
WHERE event='transaction';

SELECT *
FROM events
WHERE itemid=150318;

SELECT *
FROM events
WHERE transactionid=13556;

SELECT *
FROM events
WHERE visitorid=102019
ORDER BY timestamp;

SELECT * from events
ORDER BY timestamp DESC
limit 10;

SELECT COUNT(*)
FROM events
WHERE event="transaction";

SELECT COUNT(DISTINCT visitorid) AS TotalUniqueVisitors from events;

SELECT
    itemid,
    COUNT(*) AS Views
FROM events
WHERE event = 'view'
GROUP BY itemid
ORDER BY Views DESC
LIMIT 5;

SELECT itemid, count(*) as Purchases from events
WHERE event="transaction"
GROUP BY itemid
ORDER BY Purchases DESC
LIMIT 5;

SELECT itemid, count(*) as Addedtocart FROM events
WHERE event="addtocart"
GROUP BY itemid
ORDER BY Addedtocart DESC
LIMIT 10;

SELECT visitorid,count(Distinct itemid) as itemvisited from events
GROUP BY visitorid
HAVING itemvisited>20
ORDER BY itemvisited DESC;

SELECT itemid, COUNT(*) AS TOTAL_VIEWS FROM events
WHERE event='view'
GROUP BY itemid
HAVING TOTAL_VIEWS>1000
ORDER BY TOTAL_VIEWS DESC;

SELECT visitorid,
SUM(
	CASE
		WHEN event='view' THEN 1
        ELSE 0
	END
) as totalviews,
SUM(
	CASE
		WHEN event='addtocart' THEN 1
        ELSE 0
	END
) as totaladdtocarts
FROM events
GROUP BY visitorid
having totalviews>10 and totaladdtocarts>2
ORDER BY totalviews DESC;

SELECT VISITORID, COUNT(DISTINCT ITEMID) AS UNIQUEID FROM EVENTS
GROUP BY VISITORID
HAVING UNIQUEID=1
ORDER BY VISITORID;

SELECT
itemid,
COUNT(*) AS TotalEvents,
SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END) AS NoOfTransactions
FROM events
GROUP BY itemid
HAVING NoOfTransactions=0
ORDER BY TotalEvents DESC;

SELECT
itemid,
SUM(CASE WHEN event='ADDTOCART' THEN 1 ELSE 0 END) AS NoOfAddToCart,
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews
FROM events
GROUP BY itemid
HAVING NoOfViews=0 and NoOfAddToCart>0
ORDER BY NoOfAddToCart DESC;

SELECT
visitorid,
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews,
SUM(CASE WHEN event='ADDTOCART' THEN 1 ELSE 0 END) AS NoOfAddToCart,
SUM(CASE WHEN event='TRANSACTION' THEN 1 ELSE 0 END) AS NoOfTransactions
FROM events
GROUP BY visitorid
HAVING NoOfViews>50 and NoOfAddToCart>5 and NoOfTransactions>0
ORDER BY NoOfTransactions DESC;

SELECT
visitorid,
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews,
SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END) AS NoOfTransactions
FROM events
GROUP BY visitorid
HAVING NoOfTransactions=1 and NoOfViews>10
ORDER BY NoOfViews DESC;

SELECT
visitorid,
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews,
SUM(CASE WHEN event='ADDTOCART' THEN 1 ELSE 0 END) AS NoOfAddToCart,
SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END) AS NoOfTransactions
FROM events
GROUP BY visitorid
HAVING NoOfTransactions=0 and NoOfAddToCart=0 and NoOfViews>30
ORDER BY NoOfViews DESC;

SELECT
visitorid,
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews,
SUM(CASE WHEN event='ADDTOCART' THEN 1 ELSE 0 END) AS NoOfAddToCart,
SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END) AS NoOfTransactions
FROM events
GROUP BY visitorid
HAVING NoOfTransactions>=3 and NoOfAddToCart>=5 and NoOfViews>=20
ORDER BY NoOfTransactions DESC,NoOfAddToCart DESC;

SELECT itemid,
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews,
SUM(CASE WHEN event='ADDTOCART' THEN 1 ELSE 0 END) AS NoOfAddToCart,
SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END) AS NoOfTransactions
FROM events
GROUP BY itemid
HAVING NoOfViews>=500 and NoOfAddToCart>=50 and NoOfTransactions >=10
ORDER BY NoOfViews DESC,NoOfTransactions DESC;

SELECT
SUM(CASE WHEN event='VIEW' THEN 1 ELSE 0 END) AS NoOfViews,
SUM(CASE WHEN event='ADDTOCART' THEN 1 ELSE 0 END) AS NoOfAddToCart,
SUM(CASE WHEN event='transaction' THEN 1 ELSE 0 END) AS NoOfTransactions,
COUNT(DISTINCT visitorid) as UniqueVisitor,
COUNT(DISTINCT itemid) as UniqueProduct
FROM events;

SELECT
    MIN(TotalEvents) AS MinimumEventsPerVisitor,
    MAX(TotalEvents) AS MaximumEventsPerVisitor,
    ROUND(AVG(TotalEvents), 2) AS AverageEventsPerVisitor
FROM
(
    SELECT
        visitorid,
        COUNT(*) AS TotalEvents
    FROM events
    GROUP BY visitorid
) AS VisitorSummary;


SELECT visitorid,distinct_products FROM (
	SELECT visitorid,COUNT(Distinct itemid) as distinct_products FROM events
    GROUP BY visitorid
) as Distinct_visitor
WHERE distinct_products>(
	SELECT AVG(distinct_products)
    FROM (SELECT visitorid, COUNT(DISTINCT itemid) as distinct_products
		from events
		GROUP BY visitorid) as AvgVisitorSummary
	)
ORDER BY distinct_products DESC,visitorid;

SELECT
    itemid,
    view_count,
    transaction_count
FROM
(
    SELECT
        itemid,
        SUM(CASE WHEN event = 'view' THEN 1 ELSE 0 END) AS view_count,
        SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS transaction_count
    FROM events
    GROUP BY itemid
) AS ProductSummary
WHERE
    view_count >= 500
    AND transaction_count >
    (
        SELECT AVG(transaction_count)
        FROM
        (
            SELECT
                itemid,
                SUM(CASE WHEN event = 'transaction' THEN 1 ELSE 0 END) AS transaction_count
            FROM events
            GROUP BY itemid
        ) AS AvgTransactionSummary
    )
ORDER BY
    transaction_count DESC,
    view_count DESC;