-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103152195
-- Date: Tuesday, Feb-9-2021
-- Purpose: Lab 4 DBS311
-- Section: DBS311 NFF
-- ***********************

-- Question 1
-- Display cities that no warehouse is located in them. (use set operators to answer this
-- question)
-- Q1 Solution
SELECT city
FROM locations
MINUS
SELECT city
FROM warehouses
         INNER JOIN locations
                    ON locations.location_id = warehouses.location_id;

-- Q2
-- Display the category ID, category name, and the number of products in category 1, 2,
-- and 5. In your result, display first the number of products in category 5, then category 1
-- and then 2
-- Q2 Solution
SELECT products.category_id, category_name, COUNT(*)
FROM product_categories
         INNER JOIN products ON product_categories.category_id = products.category_id
WHERE products.category_id IN (5)
GROUP BY products.category_id, category_name
UNION ALL
SELECT product_categories.category_id, category_name, COUNT(*)
FROM product_categories
         INNER JOIN products ON product_categories.category_id = products.category_id
WHERE products.category_id IN (1, 2)
GROUP BY category_name, product_categories.category_id;

-- Q3
-- Display product ID for products whose quantity in the inventory is less than to 5. (You
-- are not allowed to use JOIN for this question)
-- Q3 Solution
SELECT product_id
FROM (
         SELECT product_id, quantity
         FROM inventories
         MINUS
         SELECT product_id, quantity
         FROM inventories
         WHERE quantity >= 5
     );

-- Q4
-- We need a single report to display all warehouses and the state that they are located in
-- and all states regardless of whether they have warehouses in them or not. (Use set
-- operators in you answer)
-- Q4 Solution
SELECT warehouse_name, state
FROM warehouses
         LEFT JOIN locations ON warehouses.location_id = locations.location_id
UNION
SELECT warehouse_name, state
FROM warehouses
         RIGHT JOIN locations ON warehouses.location_id = locations.location_id;