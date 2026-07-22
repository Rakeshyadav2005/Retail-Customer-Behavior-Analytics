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

CREATE INDEX idx_events_timestamp ON events(timestamp);
CREATE INDEX idx_events_visitorid ON events(visitorid);
CREATE INDEX idx_events_itemid ON events(itemid);
CREATE INDEX idx_events_transactionid ON events(transactionid);

CREATE INDEX idx_categories_parentid ON categories(parentid);

CREATE INDEX idx_properties_timestamp
ON properties(timestamp);
CREATE INDEX idx_properties_itemid ON properties(itemid);
CREATE INDEX idx_properties_property ON properties(property);

SHOW INDEX FROM properties;