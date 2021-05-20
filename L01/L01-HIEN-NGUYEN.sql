-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103152195
-- Date: Friday, Jan-15-2021
-- Purpose: Lab 1 DBS311NFF
-- ***********************

-- Q1
-- Write a query to display the tomorrow’s date in the following format:
-- January 10th of year 2019
-- the result will depend on the day when you RUN/EXECUTE this query. Label the column “Tomorrow”.
SELECT TO_CHAR(SYSDATE + 1, 'FMMonth DD"th of year "YYYY') AS "Tomorrow"
FROM dual;

-- Q2
-- Define an SQL variable called “tomorrow”, assign it a value of tomorrow’s date and use it
-- in an SQL statement. Here the question is asking you to use a Substitution variable. Instead of
-- using the constant values in your queries, you can use variables to store and reuse the values.
DEFINE Tomorrow = SYSDATE + 1;
SELECT TO_CHAR(&Tomorrow, 'FMMonth DD"th of year "YYYY') AS "Tomorrow"
FROM dual;
UNDEFINE Tomorrow;

-- Q3
-- For each product in category 2, 3, and 5, show product ID, product name, list price, and
-- the new list price increased by 2%. Display a new list price as a whole number.
-- In your result, add a calculated column to show the difference of old and new list prices.
-- Sort the result according to category ID first and then based on product ID.
SELECT product_id                                               AS "Product ID",
       product_name                                             AS "Product Name",
       ROUND(list_price, 2)                                     AS "List Price",
       ROUND(list_price * 1.02)                                 AS "New Price",
       ROUND(ROUND((1 + 2 / 100) * list_price) - list_price, 2) AS "Price Difference"
FROM products
WHERE category_id IN (2, 3, 5)
ORDER BY category_id, product_id;

-- Q4
-- For employees whose manager ID is 2, write a query that displays the employee’s Full
-- Name and Job Title in the following format:
-- Summer, Payne is Public Accountant.
-- Sort the result based on employee ID.
SELECT last_name
           || ', '
           || first_name
           || ' is '
           || job_title AS "Employee Info"
FROM employees
WHERE manager_id = 2
ORDER BY employee_id;

-- Q5
-- For each employee hired before October 2016, display the employee’s last name, hire
-- date and calculate the number of YEARS between TODAY and the date the employee was hired.
-- Label the column Years worked.
-- Order your results by the number of years employed. Round the number of
-- years employed up to the closest whole number.
-- The output result includes 89 rows. See the partial result (The first 10 rows).
-- If you get the result in a different order, sort the result first based on the hire date column
-- and then based on the number of years worked.
SELECT last_name                                                        AS "Last Name",
       TO_CHAR(hire_date, 'DD-MON-YY')                                  AS "Hire Date",
       TRUNC(MONTHS_BETWEEN(TO_DATE(SYSDATE), TO_DATE(hire_date)) / 12) AS "Years Worked"
FROM employees
WHERE TO_DATE('OCT-2016', 'MON-YYYY') > hire_date
ORDER BY hire_date, TO_NUMBER("Years Worked");

-- Q6
-- Display each employee’s last name, hire date, and the review date, which is the first
-- Tuesday after a year of service, but only for those hired after January 1, 2016.
-- Label the column REVIEW DAY.
-- Format the dates to appear in the format like:
-- TUESDAY, August the Thirty-First of year 2016
-- You can use ddspth to have the above format for the day.
-- Sort by review date
SELECT last_name                                                 AS "Last Name",
       TO_CHAR(hire_date, 'DD-MON-YY')                           AS "Hire Date",
       TO_CHAR(NEXT_DAY(ADD_MONTHS(hire_date, 12), 'TUESDAY'),
               '"TUESDAY", FMMonth" the" ddspth "of year "YYYY') AS "Review Date"
FROM employees
WHERE TO_DATE(hire_date) > TO_DATE('01-JAN-2016', 'DD-MON-YYYY')
ORDER BY NEXT_DAY(ADD_MONTHS(hire_date, 12), 'TUESDAY');

-- Q7
-- For all warehouses, display warehouse id, warehouse name, city, and state. For
-- warehouses with the null value for the state column, display “unknown”. Sort the result based
-- on the warehouse ID.
SELECT warehouse_id               AS "Warehouse ID",
       warehouse_name             AS "Warehouse Name",
       city                       AS "City",
       COALESCE(state, 'Unknown') AS "State"
FROM warehouses
         INNER JOIN locations
                    ON warehouses.location_id = locations.location_id
ORDER BY warehouse_id;