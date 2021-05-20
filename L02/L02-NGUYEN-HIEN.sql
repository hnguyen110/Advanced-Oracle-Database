-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103152195
-- Date: Friday, Jan-21-2021
-- Purpose: Lab 2 DBS311
-- ***********************

-- QUESTION 1
-- For each job title display the number of employees. Sort the result according to the number of employees.
-- Q1 SOLUTION
SELECT job_title,
       COUNT(*) AS employees
FROM employees
GROUP BY job_title
ORDER BY employees;

-- QUESTION 2
-- Display the highest, lowest, and average customer credit limits.
-- Name these results high, low, and average.
-- Add a column that shows the difference between the highest and the lowest credit limits named “High and Low Difference”.
-- Round the average to 2 decimal places.
-- Q2 SOLUTION
SELECT MAX(credit_limit)                     AS high,
       MIN(credit_limit)                     AS low,
       ROUND(AVG(credit_limit), 2)           AS average,
       MAX(credit_limit) - MIN(credit_limit) AS "High Low Difference"
FROM customers;

-- QUESTION 3
-- Display the order id, the total number of products, and the total order amount for orders
-- with the total amount over $1,000,000. Sort the result based on total amount from the high
-- to low values.
-- Q3 SOLUTION
SELECT *
FROM (
         SELECT order_id,
                SUM(quantity)              AS total_items,
                SUM(quantity * unit_price) AS total_amount
         FROM order_items
         GROUP BY order_id
     )
WHERE total_amount > 1000000
ORDER BY total_amount DESC;

-- QUESTION 4
-- Display the warehouse id, warehouse name, and the total number of products for each
-- warehouse. Sort the result according to the warehouse ID.
-- Q4 SOLUTION
SELECT warehouses.warehouse_id,
       warehouse_name,
       SUM(quantity) AS total_products
FROM warehouses
         INNER JOIN inventories ON warehouses.warehouse_id = inventories.warehouse_id
GROUP BY warehouses.warehouse_id, warehouse_name
ORDER BY warehouse_id;

-- QUESTION 5
-- For each customer display customer number, customer full name, and the total number of
-- orders issued by the customer.
-- If the customer does not have any orders, the result shows 0.
-- Display only customers whose customer name starts with ‘O’ and contains ‘e’.
-- Include also customers whose customer name ends with ‘t’.
-- Show the customers with highest number of orders first.
-- Q5 SOLUTION
SELECT *
FROM (
         SELECT customers.customer_id     AS "Customer ID",
                name                      AS "Customer Name",
                COUNT(orders.customer_id) AS "Total Number Of Orders"
         FROM customers
                  LEFT JOIN orders ON customers.customer_id = orders.customer_id
         WHERE name LIKE 'O%e%'
            OR name LIKE '%t'
         GROUP BY customers.customer_id, name
     )
ORDER BY "Total Number Of Orders" DESC;

-- QUESTION 6
-- Write a SQL query to show the total and the average sale amount for each category. Round
-- the average to 2 decimal places.
-- Q6 SOLUTION
SELECT category_id,
       ROUND(SUM(quantity * unit_price), 2)             AS total_amount,
       ROUND(AVG(quantity * order_items.unit_price), 2) AS average_amount
FROM order_items
         INNER JOIN products ON order_items.product_id = products.product_id
GROUP BY category_id;