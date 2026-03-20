CREATE DATABASE ecommerce_analysis;
USE ecommerce_analysis;
CREATE TABLE events(
event_time BIGINT,
visitor_id BIGINT,
event_type VARCHAR(50),
item_id BIGINT,
transaction_id BIGINT
);
CREATE TABLE Category_tree(
Category_id BIGINT,
parent_id BIGINT
);
CREATE TABLE item_properties(
event_time BIGINT,
item_id BIGINT,
property VARCHAR(50),
value TEXT
);
SELECT COUNT(*) FROM events;
SELECT COUNT(*) FROM item_properties;
SELECT 
SUM(visitor_id IS NULL) AS null_visitor,
SUM(event_type IS NULL) AS null_event,
SUM(event_time IS NULL) AS null_time
FROM events;
SELECT 
  SUM(category_id IS NULL) AS null_category,
  SUM(parent_id IS NULL) AS null_parent
FROM category_tree;
 SELECT 
  SUM(item_id IS NULL) AS null_item,
  SUM(property IS NULL) AS null_property,
  SUM(value IS NULL) AS null_value
FROM item_properties;
SELECT 
  event_type,
  COUNT(DISTINCT visitor_id) AS users
FROM events
WHERE event_type IN ('view','addtocart','transaction')
GROUP BY event_type;
SELECT 
  ROUND(
    COUNT(DISTINCT CASE WHEN event_type='addtocart' THEN visitor_id END)*100.0 /
    COUNT(DISTINCT CASE WHEN event_type='view' THEN visitor_id END),2) AS cart_rate,
    
  ROUND(
    COUNT(DISTINCT CASE WHEN event_type='transaction' THEN visitor_id END)*100.0 /
    COUNT(DISTINCT CASE WHEN event_type='addtocart' THEN visitor_id END),2) AS purchase_rate
FROM events;
SELECT 
  visitor_id,
  MIN(CASE WHEN event_type='view' THEN event_time END) AS first_view,
  MIN(CASE WHEN event_type='addtocart' THEN event_time END) AS first_cart,

  (MIN(CASE WHEN event_type='addtocart' THEN event_time END) 
   - MIN(CASE WHEN event_type='view' THEN event_time END)) AS time_to_cart

FROM events
GROUP BY visitor_id
HAVING first_cart IS NOT NULL;

SELECT 
  visitor_id,
  MIN(CASE WHEN event_type='view' THEN event_time END) AS first_view,
  MIN(CASE WHEN event_type='transaction' THEN event_time END) AS first_purchase,

  (MIN(CASE WHEN event_type='transaction' THEN event_time END) 
   - MIN(CASE WHEN event_type='view' THEN event_time END)) AS time_to_purchase

FROM events
GROUP BY visitor_id
HAVING first_purchase IS NOT NULL;

SELECT 
  CASE 
    WHEN (MIN(CASE WHEN event_type='transaction' THEN event_time END) 
         - MIN(CASE WHEN event_type='view' THEN event_time END)) < 100000 
    THEN 'Fast Converter'
    ELSE 'Slow Converter'
  END AS user_type,

  COUNT(*) AS users

FROM events
GROUP BY visitor_id;

SELECT 
  visitor_id,
  COUNT(*) AS total_events

FROM events
GROUP BY visitor_id
HAVING total_events > 50 
AND visitor_id NOT IN (
  SELECT visitor_id FROM events WHERE event_type='transaction'
)
ORDER BY total_events DESC;

SELECT 
  item_id,

  COUNT(DISTINCT CASE WHEN event_type='view' THEN visitor_id END) AS views,
  COUNT(DISTINCT CASE WHEN event_type='transaction' THEN visitor_id END) AS purchases

FROM events
GROUP BY item_id
HAVING views > 500
ORDER BY views DESC;