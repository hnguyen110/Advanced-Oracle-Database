-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103152195
-- Date: Friday, Jan-29-2021
-- Purpose: Lab 3 DBS311
-- Section: DBS311 NFF
-- ***********************

-- Q1 QUESTION
-- Write a SQL query to display the last name and hire date of all employees who were hired before the
-- employee with ID 107 got hired but after March 2016. Sort the result by the hire date and then
-- employee ID.
-- Q1 SOLUTION
SELECT last_name,
       TO_CHAR(hire_date, 'DD-MON-YY') AS hire_date
FROM employees
WHERE hire_date > TO_DATE('01-04-2016', 'DD-MM-YYYY')
  AND hire_date < (SELECT hire_date FROM employees WHERE employee_id = 107)
ORDER BY TO_DATE(hire_date, 'DD-MON-YY'), employee_id;

-- Q2 QUESTION
-- Write a SQL query to display customer name and credit limit for customers with lowest credit limit. Sort
-- the result by customer ID.
-- Q2 SOLUTION
SELECT name,
       credit_limit
FROM customers
WHERE credit_limit = (SELECT MIN(credit_limit) FROM customers)
ORDER BY customer_id;

-- Q3 QUESTION
-- Write a SQL query to display the product ID, product name, and list price of the highest paid product(s)
-- in each category. Sort by category ID and the product ID.
-- Q3 SOLUTION
SELECT category_id,
       product_id,
       product_name,
       list_price
FROM products
WHERE list_price IN
      (SELECT MAX(list_price)
       FROM products
       GROUP BY category_id)
ORDER BY category_id, product_id;

-- Q4 QUESTION
-- Write a SQL query to display the category ID and the category name of the most expensive (highest list
-- price) product(s).
-- Q4 SOLUTION
SELECT product_categories.category_id   AS category_id,
       product_categories.category_name AS category_name
FROM product_categories
         INNER JOIN products
                    ON product_categories.category_id = products.category_id
WHERE list_price = (SELECT MAX(list_price) FROM products);

-- Q5 QUESTION
-- Write a SQL query to display product name and list price for products in category 1 which have the list
-- price less than the lowest list price in ANY category. Sort the output by top list prices first and then by
-- the product ID.
-- Q5 SOLUTION
SELECT product_name,
       list_price
FROM products
WHERE list_price < ANY
      (SELECT MIN(list_price)
       FROM products
       GROUP BY category_id)
  AND category_id = 1
ORDER BY list_price DESC, product_id;

-- Q6 QUESTION
-- Display the maximum price (list price) of the category(s) that has the lowest price product.
-- Q6 SOLUTION
SELECT MAX(list_price)
FROM products
WHERE category_id =
      (SELECT category_id
       FROM products
       WHERE list_price =
             (SELECT MIN(list_price)
              FROM products));