CREATE DATABASE pizza_sales;
USE pizza_sales;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);

SELECT count(*) AS total_orders FROM pizza_sales.orders;
truncate table orders;

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT
);
SELECT COUNT(*) AS total_order_details FROM pizza_sales.order_details;

CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id VARCHAR(50),
    size VARCHAR(10),
    price DECIMAL(10,2)
);
SELECT * FROM pizza_sales.pizzas;

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150),
    category VARCHAR(50),
    ingredients TEXT
);
SELECT * FROM pizza_sales.pizza_types;

### QUESTIONS: ###

# 1. How many unique orders are present?
SELECT DISTINCT order_id AS unique_orders FROM orders;

# 2. How many pizzas were sold in total?
SELECT SUM(quantity) AS total_pizzas_sold FROM order_details;

# 3. What is total revenue, using quantity × pizza price?
SELECT SUM(od.quantity * p.price) AS total_revenue FROM order_details od JOIN pizzas p ON od.pizza_id = p.pizza_id;

# 4. What is the average order value?
SELECT SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id) AS average_order_value FROM orders o LEFT JOIN order_details od ON o.order_id = od.order_id LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id;

# 5. How many pizzas are sold per order on average?
SELECT AVG(od.quantity) AS average_pizzas_per_order FROM orders o LEFT JOIN order_details od ON o.order_id = od.order_id;

# 6. What is monthly revenue and monthly order count?
SELECT
    MONTH(o.date) AS month,
    SUM(od.quantity * p.price) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS monthly_orders
FROM orders o
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY MONTH(o.date)
ORDER BY month;

# 7. What is revenue and quantity by pizza category?
SELECT
    category,
    SUM(od.quantity * p.price) AS revenue,
    SUM(od.quantity) AS quantity
FROM orders o
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id
LEFT JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY category;

# 8. What is revenue and quantity by pizza size?
SELECT
    p.size,
    SUM(od.quantity * p.price) AS revenue,
    SUM(od.quantity) AS quantity
FROM orders o
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size;

# 9. Which pizza types have the highest revenue?
SELECT
    pt.name AS pizza_name,
    SUM(od.quantity * p.price) AS revenue
FROM orders o
LEFT JOIN order_details od ON o.order_id = od.order_id
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id
LEFT JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY revenue DESC;

# 10. Which pizza types have the highest quantity sold?
SELECT
    pt.name AS pizza_type,
    SUM(od.quantity) AS quantity_sold
FROM order_details od
LEFT JOIN pizzas p ON od.pizza_id = p.pizza_id
LEFT JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY quantity_sold DESC;

# 11. How do orders vary by weekday?
SELECT WEEKDAY(o.date) AS weekday, COUNT(DISTINCT o.order_id) AS total_orders FROM orders o GROUP BY WEEKDAY(o.date) ORDER BY weekday;

# 12. How do orders vary by hour of day?
SELECT HOUR(o.time) AS hour, COUNT(DISTINCT o.order_id) AS total_orders FROM orders o GROUP BY HOUR(o.time) ORDER BY hour;

# 13. What are the top 3 pizza types within each category by revenue?
SELECT
    pt.category,
    pt.name AS pizza_type,
    SUM(od.quantity * p.price) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
ORDER BY revenue DESC
LIMIT 3;

# 14. Calculate month-over-month revenue using a window function or equivalent SQL technique.
SELECT
    MONTH(o.date) AS month,
    SUM(od.quantity * p.price) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY MONTH(o.date)
ORDER BY month; 

# 15. Calculate a running cumulative revenue by month.
SELECT
    MONTH(o.date) AS month,
    SUM(od.quantity * p.price) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY MONTH(o.date)
ORDER BY month;

# 16. Rank pizza types within each category by revenue.
SELECT
    pt.category,
    pt.name AS pizza_type,
    SUM(od.quantity * p.price) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category, pt.name
ORDER BY pt.category, revenue DESC;


CREATE TABLE pizza_sales_all_data AS
SELECT
    o.order_id,
    o.date,
    o.time,
    od.order_details_id,
    od.pizza_id,
    p.pizza_type_id,
    pt.name,
    pt.category,
    pt.ingredients,
    p.size,
    p.price,
    od.quantity,
    od.quantity * p.price AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;

SELECT * FROM pizza_sales_all_data;