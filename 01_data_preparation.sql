-- Prepare analysis-ready temporary tables by joining raw order-level data 
-- with product, aisle, and department details.


-- 1) Create a temporary table that joins the orders, order_products, and products tables
-- to get information about each order, including the products purchased and their
-- department and aisle information.

CREATE TEMPORARY TABLE order_info AS
SELECT 
    o.order_id,
    o.order_number,
    o.order_dow,
    o.order_hour_of_day,
    o.days_since_prior_order,
    op.product_id,
    op.add_to_cart_order,
    op.reordered,
    p.product_name,
    p.aisle_id,
    p.department_id
FROM orders AS o
JOIN order_products AS op 
    ON o.order_id = op.order_id
JOIN products AS p 
    ON op.product_id = p.product_id;


-- 2) Create a temporary table that groups orders by product and finds the total
-- number of times each product was purchased, total number of times reordered,
-- and the average cart position.

CREATE TEMPORARY TABLE product_order_summary AS
SELECT 
    product_id,
    product_name,
    COUNT(*) AS total_orders,
    COUNT(CASE WHEN reordered = 1 THEN 1 END) AS total_reorders,
    AVG(add_to_cart_order) AS avg_add_to_cart
FROM order_info
GROUP BY product_id, product_name;


-- 3) Create a temporary table that groups orders by department and finds the total
-- number of products purchased, number of unique products purchased, weekday vs weekend
-- purchases, and average order time.

CREATE TEMPORARY TABLE department_order_summary AS
SELECT 
    department_id,
    COUNT(*) AS total_purchased_order,
    COUNT(DISTINCT product_id) AS number_of_unique_products,
    COUNT(CASE WHEN order_dow < 6 THEN 1 END) AS total_weekdays_purchases,
    COUNT(CASE WHEN order_dow > 5 THEN 1 END) AS total_weekend_purchases,
    AVG(order_hour_of_day) AS avg_order_time
FROM order_info
GROUP BY department_id;


-- 4) Create a temporary table that identifies the top 10 most popular aisles,
-- including total purchased products and unique products purchased.

CREATE TEMPORARY TABLE aisle_order_summary AS
SELECT 
    aisle_id,
    COUNT(*) AS total_purchased_products,
    COUNT(DISTINCT product_id) AS purchased_unique_products
FROM order_info
GROUP BY aisle_id
ORDER BY total_purchased_products DESC
LIMIT 10;


-- 5) Combine the previous temporary tables into a final product analysis table
-- showing product, department, aisle, purchase, reorder, and department-level metrics.

CREATE TEMPORARY TABLE product_analysis AS
SELECT 
    pi.product_id,
    pi.product_name,
    pi.department_id,
    d.department,
    pi.aisle_id,
    a.aisle,
    pos.total_orders,
    pos.total_reorders,
    pos.avg_add_to_cart,
    dos.total_purchased_order,
    dos.number_of_unique_products,
    dos.total_weekdays_purchases,
    dos.total_weekend_purchases,
    dos.avg_order_time
FROM product_order_summary AS pos
JOIN products AS pi 
    ON pos.product_id = pi.product_id
JOIN departments AS d 
    ON pi.department_id = d.department_id
JOIN aisles AS a 
    ON pi.aisle_id = a.aisle_id
JOIN department_order_summary AS dos 
    ON dos.department_id = pi.department_id;
	
	
	




