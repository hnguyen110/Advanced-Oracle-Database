-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103152195
-- Date: Feb 19 2021
-- Purpose: Lab 5 DBS311
-- ***********************

-- SET SERVEROUTPUT ON;

-- Question 1
-- Write a store procedure that get an integer number and prints
-- The number is even.
-- If a number is divisible by 2.
-- Otherwise, it prints
-- The number is odd.
-- Q1 Solution
CREATE OR REPLACE PROCEDURE even_or_odd(num IN NUMBER) AS
    remainder NUMBER;
BEGIN
    remainder := MOD(num, 2);
    IF (remainder = 0) THEN
        dbms_output.put_line('The number is even.');
    ELSE
        dbms_output.put_line('The number is odd.');
    END IF;
END;

-- Question 2
-- Create a stored procedure named find_employee. This procedure gets an employee number
-- and prints the following employee information:
-- First name
-- Last name
-- Email
-- Phone
-- Hire date
-- Job title
-- The procedure gets a value as the employee ID of type NUMBER.
-- See the following example for employee ID 107:
-- First name: Summer
-- Last name: Payn
-- Email: summer.payne@example.com
-- Phone: 515.123.8181
-- Hire date: 07-JUN-16
-- Job title: Public Accountant
-- The procedure display a proper error message if any error occurs.
-- Q2 Solution
CREATE OR REPLACE PROCEDURE find_employee(employee_no IN NUMBER) AS
    first_name VARCHAR2(255 BYTE);
    last_name  VARCHAR2(255 BYTE);
    email      VARCHAR2(255 BYTE);
    phone      VARCHAR2(255 BYTE);
    hire_date  DATE;
    job_title  VARCHAR2(255 BYTE);
BEGIN
    SELECT first_name,
           last_name,
           email,
           phone,
           hire_date,
           job_title
    INTO
        first_name,
        last_name,
        email,
        phone,
        hire_date,
        job_title
    FROM employees
    WHERE employee_id = employee_no;
    dbms_output.put_line('First name: ' || first_name);
    dbms_output.put_line('Last name: ' || last_name);
    dbms_output.put_line('Email: ' || email);
    dbms_output.put_line('Phone: ' || phone);
    dbms_output.put_line('Hire date: ' || TO_CHAR(hire_date, 'DD-MON-YY'));
    dbms_output.put_line('Job title: ' || job_title);
EXCEPTION
    WHEN no_data_found
        THEN
            dbms_output.put_line('Employee does not exist !!!');
    WHEN OTHERS
        THEN
            dbms_output.put_line('Server was failed to process your request, please try again !!!');
END;

-- Question 3
-- Every year, the company increases the price of all products in one category. For example, the
-- company wants to increase the price (list_price) of products in category 1 by $5. Write a
-- procedure named update_price_by_cat to update the price of all products in a given category
-- and the given amount to be added to the current price if the price is greater than 0. The
-- procedure shows the number of updated rows if the update is successful.
-- Q3 Solution
CREATE OR REPLACE PROCEDURE update_price_by_cat(category_no IN NUMBER, amount IN NUMBER) AS
    updated_rows NUMBER;
BEGIN
    UPDATE products
    SET list_price = list_price + amount
    WHERE category_id = category_no
      AND list_price > 0;
    updated_rows := SQL%ROWCOUNT;
    IF updated_rows = 0 THEN
        dbms_output.put_line('Nothing was updated !!!');
    ELSE
        dbms_output.put_line(updated_rows || ' rows were updated');
    END IF;

EXCEPTION
    WHEN no_data_found
        THEN
            dbms_output.put_line('Category does not exist !!!');
    WHEN OTHERS
        THEN
            dbms_output.put_line('Server was failed to process your request, please try again !!!');
END;

-- Question 4
-- Every year, the company increase the price of products whose price is less than the average
-- price of all products by 1%. (list_price * 1.01). Write a stored procedure named
-- update_price_under_avg. This procedure do not have any parameters. You need to find the
-- average price of all products and store it into a variable of the same type. If the average price
-- is less than or equal to $1000, update products’ price by 2% if the price of the product is less
-- than the calculated average. If the average price is greater than $1000, update products’ price
-- by 1% if the price of the product is less than the calculated average. The query displays an
-- error message if any error occurs. Otherwise, it displays the number of updated rows.
-- Q4 Solution
CREATE OR REPLACE PROCEDURE update_price_under_avg AS
    average NUMBER := 0;
BEGIN
    SELECT AVG(list_price) INTO average FROM products;
    IF (average <= 1000) THEN
        UPDATE products SET list_price = list_price * 1.02 WHERE list_price < average;
    ELSE
        UPDATE products SET list_price = list_price * 1.02 WHERE list_price < average;
    END IF;
    dbms_output.put_line(SQL%ROWCOUNT || ' rows were updated');
EXCEPTION
    WHEN OTHERS
        THEN
            dbms_output.put_line('Server was failed to process your request, please try again !!!');
END;

-- Question 5
-- The company needs a report that shows three category of products based their prices. The
-- company needs to know if the product price is cheap, fair, or expensive. Let’s assume that
-- If the list price is less than
-- (avg_price - min_price) / 2
-- The product’s price is cheap.
-- If the list price is greater than
-- (max_price - avg_price) / 2
-- The product’ price is expensive.
-- If the list price is between
-- (avg_price - min_price) / 2
-- and
-- (max_price - avg_price) / 2
-- the end values included
-- The product’s price is fair.
-- Write a procedure named product_price_report to show the number of products in each price
-- category:
-- The following is a sample output of the procedure if no error occurs:
-- Cheap: 10
-- Fair: 50
-- Expensive: 18
-- Q5 Solution
CREATE OR REPLACE PROCEDURE product_price_report AS
    cheap     NUMBER;
    fair      NUMBER;
    expensive NUMBER;
    min_price NUMBER;
    max_price NUMBER;
    average   NUMBER;
BEGIN
    SELECT AVG(list_price) INTO average FROM products;
    SELECT MIN(list_price) INTO min_price FROM products;
    SELECT MAX(list_price) INTO max_price FROM products;

    SELECT COUNT(*)
    INTO cheap
    FROM products
    WHERE list_price < (average - min_price) / 2;

    SELECT COUNT(*)
    INTO fair
    FROM products
    WHERE list_price BETWEEN (average - min_price) / 2 AND (max_price - average) / 2;

    SELECT COUNT(*)
    INTO expensive
    FROM products
    WHERE list_price > (max_price - average) / 2;

    dbms_output.put_line('Cheap: ' || cheap);
    dbms_output.put_line('Fair: ' || fair);
    dbms_output.put_line('Expensive: ' || expensive);

EXCEPTION
    WHEN OTHERS
        THEN
            dbms_output.put_line('Server was failed to process your request, please try again !!!');
END;

BEGIN
    even_or_odd(10);
    find_employee(107);
    update_price_by_cat(1, 5.0);
    update_price_under_avg();
    product_price_report();
END;