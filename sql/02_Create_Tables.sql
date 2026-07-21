USE retail_analytics;
CREATE TABLE events (
    timestamp DATETIME NOT NULL,
    visitorid BIGINT NOT NULL,
    event VARCHAR(20) NOT NULL,
    itemid BIGINT NOT NULL,
    transactionid BIGINT NULL
);
desc events;

CREATE TABLE categories (
    categoryid BIGINT PRIMARY KEY,
    parentid BIGINT NULL
);

DESC categories;

CREATE TABLE properties (
    timestamp DATETIME NOT NULL,
    itemid BIGINT NOT NULL,
    property VARCHAR(100) NOT NULL,
    value VARCHAR(255) NOT NULL
);

DESC properties;
DESC events;
DESC categories;

SHOW TABLES;