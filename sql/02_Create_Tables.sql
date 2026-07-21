USE retail_analytics;
CREATE TABLE events (
    timestamp DATETIME,
    visitorid BIGINT,
    event VARCHAR(20),
    itemid BIGINT,
    transactionid VARCHAR(20)
);
desc events;

CREATE TABLE categories(
categoryid INT,
parentid INT
);

DESC categories;

CREATE TABLE properties(
timestamp DATETIME,
itemid BIGINT,
property VARCHAR(100),
value VARCHAR(225)
);

DESC properties;
DESC events;
DESC categories;

SHOW TABLES;
