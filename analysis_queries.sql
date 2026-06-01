USE customer_retention_portfolio;

----------------------------------------------------------------------------------------
-- Step 1: Basic customer analysis
----------------------------------------------------------------------------------------

-- Query 1: total customers
SELECT
	COUNT(*) AS total_customers
FROM customers;
-- This query calculates the total number of registered customers in the dataset

-- Query 2: Customers with completed orders
SELECT
	 COUNT(DISTINCT customer_id) AS customers_with_orders
FROM orders
WHERE order_status = 'Completed';
-- This query counts how many customers made at least one completed purchase.

-- Query 3: Customer with no completed orders
SELECT
	c.customer_id,
    c.customer_name,
    c.city,
    c.signup_date
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
WHERE o.order_Id IS NULL;
-- This query identifies registered customers who have not made any completed purchase. These customers may need onboarding campaigns or first-purchase incentives.    

----------------------------------------------------------------------------------------
-- Step 2: Customer purchase frequency
----------------------------------------------------------------------------------------

-- Query 4: Number of completed orders by customer
SELECT
	c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS completed_orders
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY completed_orders DESC;
-- This query calculates completed purchase frequency for each customer, including customers with zero completed orders.

-- Query 5: Repeat vs one-time vs no-purchase customers
WITH customer_order_count AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS completed_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    CASE
        WHEN completed_orders = 0 THEN 'No Purchase'
        WHEN completed_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS customer_segment,
    COUNT(*) AS total_customers
FROM customer_order_count
GROUP BY
    CASE
        WHEN completed_orders = 0 THEN 'No Purchase'
        WHEN completed_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END
ORDER BY total_customers DESC;
-- This query segments customers based on completed purchase behavior. This table helps the business to understand how many customers are retained, one-time buyers, or not yet converted.

----------------------------------------------------------------------------------------
-- Step 3: First and latest purchase date
----------------------------------------------------------------------------------------

-- Query 6: First and latest purchase by customers
SELECT
	c.customer_id,
    c.customer_name,
    MIN(o.order_date) AS first_purchase_date,
    MAX(o.order_date) AS latest_purchase_date,
    COUNT(o.order_id) AS completed_orders
FROM customers c
LEFT JOIN orders o
	ON c.customer_id = o.customer_id
    AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY latest_purchase_date DESC;
-- This query identifies each customer's first and latest completed purchase date.

-- Query 7: Customer activity status (assume the latest analysis date is 30 April 2026)
WITH customer_activity AS (
    SELECT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) AS latest_purchase_date
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)

SELECT
    customer_id,
    customer_name,
    latest_purchase_date,
    CASE
        WHEN latest_purchase_date IS NULL THEN 'No Purchase'
        WHEN DATEDIFF('2026-04-30', latest_purchase_date) <= 30 THEN 'Active'
        WHEN DATEDIFF('2026-04-30', latest_purchase_date) BETWEEN 31 AND 60 THEN 'At Risk'
        ELSE 'Inactive'
    END AS customer_status
FROM customer_activity
ORDER BY latest_purchase_date DESC;
-- This query classifies customers based on recency of their latest purchase. It helps the business identify active, at-risk, inactive, and no-purchase customers.

----------------------------------------------------------------------------------------
-- Step 8: Customer lifetime value
----------------------------------------------------------------------------------------

-- Query 8: customer lifetime values
SELECT
	c.customer_id,
    c.customer_name,
    ROUND(SUM(oi.quantity*oi.unit_price), 2) AS customer_lifetime_value
FROM customers c
JOIN orders o
	ON c.customer_id = o.customer_id
JOIN order_items oi
	ON o.order_id = oi.order_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_lifetime_value DESC;
-- This query calculates customer lifetime value based on total completed purchase revenue. It helps identify the most valuable customers

-- Query 9: Customer value segment (clv)
-------------------------------------------
-- high value: CLV >= 300
-- medium value: CLV >= 150 and <300
-- low value: CLV < 150
-- no purchase: no revenue
--------------------------------------------

WITH customer_value AS (
    SELECT
        c.customer_id,
        c.customer_name,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS customer_lifetime_value
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Completed'
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    ROUND(customer_lifetime_value, 2) AS customer_lifetime_value,
    CASE
        WHEN customer_lifetime_value = 0 THEN 'No Purchase'
        WHEN customer_lifetime_value >= 300 THEN 'High Value'
        WHEN customer_lifetime_value >= 150 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment
FROM customer_value
ORDER BY customer_lifetime_value DESC;
-- This query calculates customer retention rate by measuring the percentage of purchasing customers who made more than one completed order.

----------------------------------------------------------------------------------------
-- Step 9: Retention rate (Retention Rate = Repeat Customers / Customers With Completed Orders × 100)
----------------------------------------------------------------------------------------

-- Query 10: Customer retention rate
WITH customer_orders AS (
	SELECT
		customer_id,
        COUNT(order_id) AS completed_orders
	FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),

retention_summary AS (
	SELECT
		COUNT(*) AS customers_with_orders,
        SUM(CASE WHEN completed_orders > 1 THEN 1 ELSE 0 END) AS repeated_customers
	FROM customer_orders
)
SELECT
	customers_with_orders,
    repeated_customers,
    ROUND(repeated_customers*100/customers_with_orders, 2) AS retention_rate_percentage
FROM retention_summary;
-- This query calculates customer retention rate by measuring the percentage of purchasing customers who made more than one completed order.

----------------------------------------------------------------------------------------
-- Step 10: New vs returning customers by month
----------------------------------------------------------------------------------------

-- Query 11: Monthly new vs returning customers
WITH customer_first_order AS (
	SELECT
		customer_id,
        MIN(order_date) AS first_order_date
	FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),

monthly_customer_type AS (
	SELECT
		DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
        o.customer_id,
        CASE
			WHEN DATE_FORMAT(o.order_date, '%Y-%m') = DATE_FORMAT(cfo.first_order_date, '%Y-%m')
				THEN 'New Customer'
			ELSE 'Returning Customer'
		END AS customer_type
	FROM orders o
    JOIN customer_first_order cfo
		ON o.customer_id = cfo.customer_id
	WHERE o.order_status = 'Completed' 
)

SELECT
	order_month,
    customer_type,
    COUNT(DISTINCT customer_id) AS total_customers
FROM monthly_customer_type
GROUP BY order_month, customer_type
ORDER BY order_month, customer_type;
-- This query compares new and returning customers by month. It helps the business understand whether growth is driven by new customer acquisition or repeat purchases.

----------------------------------------------------------------------------------------
-- Step 11: Days between purchases
----------------------------------------------------------------------------------------

-- Query 12: Days between customer purchases
WITH customer_purchase_sequence AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_date
    FROM orders
    WHERE order_status = 'Completed'
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF(order_date, previous_order_date) AS days_between_purchases
FROM customer_purchase_sequence
ORDER BY customer_id, order_date;
-- This query uses a window function to calculate the number of days between customer purchases. It helps measure repeat purchase timing and customer buying frequency.

-- Query 13: Average days between purchases
WITH customer_purchase_sequence AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_order_date
    FROM orders
    WHERE order_status = 'Completed'
),
purchase_gaps AS (
    SELECT
        customer_id,
        DATEDIFF(order_date, previous_order_date) AS days_between_purchases
    FROM customer_purchase_sequence
    WHERE previous_order_date IS NOT NULL
)
SELECT
    ROUND(AVG(days_between_purchases), 2) AS avg_days_between_purchases
FROM purchase_gaps;
-- This query calculates the average time between repeat purchases. It helps estimate the normal repurchase cycle for customers.

----------------------------------------------------------------------------------------
-- Step 12: Churn risk analysis 
-- (A customer is considered churn risk if they previously purchased but have not purchased in the last 60 days.)
----------------------------------------------------------------------------------------

-- Query 14: Churn risk customers
WITH customer_last_purchase AS (
    SELECT
        c.customer_id,
        c.customer_name,
        MAX(o.order_date) AS latest_purchase_date,
        COUNT(o.order_id) AS completed_orders
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Completed'
    GROUP BY c.customer_id, c.customer_name
)
SELECT
    customer_id,
    customer_name,
    latest_purchase_date,
    completed_orders,
    DATEDIFF('2026-04-30', latest_purchase_date) AS days_since_last_purchase
FROM customer_last_purchase
WHERE completed_orders > 0
  AND DATEDIFF('2026-04-30', latest_purchase_date) > 60
ORDER BY days_since_last_purchase DESC;
-- This query identifies customers who previously purchased but have not returned for more than 60 days. These customers may be targeted with win-back campaigns.

----------------------------------------------------------------------------------------
-- Step 13: Full customer retention summary
----------------------------------------------------------------------------------------

-- Query 15: Customer retention performance summary
WITH customer_summary AS (
    SELECT
        c.customer_id,
        c.customer_name,
        c.city,
        MIN(o.order_date) AS first_purchase_date,
        MAX(o.order_date) AS latest_purchase_date,
        COUNT(o.order_id) AS completed_orders,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS customer_lifetime_value
    FROM customers c
    LEFT JOIN orders o
        ON c.customer_id = o.customer_id
        AND o.order_status = 'Completed'
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.city
)

SELECT
    customer_id,
    customer_name,
    city,
    first_purchase_date,
    latest_purchase_date,
    completed_orders,
    ROUND(customer_lifetime_value, 2) AS customer_lifetime_value,
    CASE
        WHEN completed_orders = 0 THEN 'No Purchase'
        WHEN completed_orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS purchase_segment,
    CASE
        WHEN customer_lifetime_value = 0 THEN 'No Purchase'
        WHEN customer_lifetime_value >= 300 THEN 'High Value'
        WHEN customer_lifetime_value >= 150 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_segment,
    CASE
        WHEN latest_purchase_date IS NULL THEN 'No Purchase'
        WHEN DATEDIFF('2026-04-30', latest_purchase_date) <= 30 THEN 'Active'
        WHEN DATEDIFF('2026-04-30', latest_purchase_date) BETWEEN 31 AND 60 THEN 'At Risk'
        ELSE 'Inactive'
    END AS activity_status
FROM customer_summary
ORDER BY customer_lifetime_value DESC;
-- This query creates a full customer retention summary including first purchase date, latest purchase date, completed orders, customer lifetime value, purchase segment, value segment, and activity status.









