create database ecmrse ;
use  ecmrse ;
select * from ecommerce_user_data ;
-- 1. Find the top 5 most viewed product categories.
SELECT category, COUNT(*) AS total_views
FROM ecommerce_user_data
WHERE event_type = 'view'
GROUP BY category
ORDER BY total_views DESC
LIMIT 5;
-- 2. Calculate the conversion rate (purchase/view) for each category.

SELECT 
  category,
  COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) * 1.0 /
  COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS conversion_rate
FROM ecommerce_user_data
GROUP BY category;
-- 3. Find users who added a product to cart but never purchased.

SELECT DISTINCT user_id
FROM ecommerce_user_data
WHERE event_type = 'add_to_cart'
AND user_id NOT IN (
    SELECT DISTINCT user_id
    FROM ecommerce_user_data
    WHERE event_type = 'purchase'
);
-- 4. Find average session duration for users who made purchases.

SELECT user_id, 
       session_id,
       MAX(event_time) - MIN(event_time) AS session_duration
FROM ecommerce_user_data
WHERE user_id IN (
    SELECT DISTINCT user_id FROM ecommerce_user_data WHERE event_type = 'purchase'
)
GROUP BY user_id, session_id;
-- 5. Identify peak shopping hours.
SELECT EXTRACT(HOUR FROM event_time) AS hour, COUNT(*) AS events
FROM ecommerce_user_data
GROUP BY hour
ORDER BY events DESC;
-- 6. Show top 3 cities with the highest total purchase value.
SELECT location, SUM(price) AS total_sales
FROM ecommerce_user_data
WHERE event_type = 'purchase'
GROUP BY location
ORDER BY total_sales DESC
LIMIT 3;
-- 7. Detect abandoned carts (product added to cart but no purchase in same session).
SELECT session_id, user_id
FROM ecommerce_user_data
WHERE event_type = 'add_to_cart'
AND session_id NOT IN (
    SELECT session_id FROM ecommerce_user_data WHERE event_type = 'purchase'
)
GROUP BY session_id, user_id;
-- 8. Find most used payment method.
SELECT payment_method, COUNT(*) AS usage_count
FROM ecommerce_user_data
WHERE event_type = 'purchase'
GROUP BY payment_method
ORDER BY usage_count DESC
LIMIT 1;
-- 9. Get the top 5 devices used for purchases.
SELECT device_type, COUNT(*) AS purchase_count
FROM ecommerce_user_data
WHERE event_type = 'purchase'
GROUP BY device_type
ORDER BY purchase_count DESC
LIMIT 5;
-- 10. Which product has the highest number of unique users viewing it?
SELECT product_id, COUNT(DISTINCT user_id) AS unique_views
FROM ecommerce_user_data
WHERE event_type = 'view'
GROUP BY product_id
ORDER BY unique_views DESC
LIMIT 1;
-- 11. For each user, calculate total sessions and purchases.
SELECT user_id,
       COUNT(DISTINCT session_id) AS total_sessions,
       COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_purchases
FROM ecommerce_user_data
GROUP BY user_id;
-- 12. What percentage of sessions ended in a purchase?
SELECT 
  (SELECT COUNT(DISTINCT session_id) 
   FROM ecommerce_user_data WHERE event_type = 'purchase') * 100.0 /
  COUNT(DISTINCT session_id) AS session_conversion_percentage
FROM ecommerce_user_data;
-- 13. What is the average order value (AOV) per product category?
SELECT category, 
       AVG(price) AS avg_order_value
FROM ecommerce_user_data
WHERE event_type = 'purchase'
GROUP BY category;
-- 14. Which users have purchased from more than 2 different categories?
SELECT user_id
FROM ecommerce_user_data
WHERE event_type = 'purchase'
GROUP BY user_id
HAVING COUNT(DISTINCT category) > 2;
-- 15. Rank users by total amount spent (top 10 spenders).
SELECT user_id, SUM(price) AS total_spent,
       RANK() OVER (ORDER BY SUM(price) DESC) AS spending_rank
FROM ecommerce_user_data
WHERE event_type = 'purchase'
GROUP BY user_id
LIMIT 10;
