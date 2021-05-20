-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103 152 195
-- Date: April - 15 - 2021
-- Purpose: Assignment 2 PL/SQL DBS311NFF
-- ***********************

-- Question 1
-- This procedure has an input parameter to receive the customer ID and an output
-- parameter named found.
-- This procedure looks for the given customer ID in the database. If the customer exists, it
-- sets the variable found to 1. Otherwise, the found variable is set to 0.
-- Q1 Solution
CREATE OR REPLACE PROCEDURE find_customer(id IN NUMBER, found OUT NUMBER)
AS
BEGIN
    SELECT customer_id
    INTO found
    FROM customers
    WHERE customer_id = id;
EXCEPTION
    WHEN no_data_found THEN
        found := 0;
    WHEN OTHERS THEN
        found := 0;
        dbms_output.put_line('Unexpected Error');
END;

DECLARE
    found NUMBER;
BEGIN
    find_customer(999999, found);
    dbms_output.put_line(found);
END;

-- Question 2
-- This procedure has an input parameter to receive the product ID and an output parameter
-- named price.
-- This procedure looks for the given product ID in the database. If the product exists, it stores
-- the product’s list_price in the variable price. Otherwise, the price variable is set to 0.
-- Q2 Solution
CREATE OR REPLACE PROCEDURE find_product(id IN NUMBER, price OUT products.LIST_PRICE%TYPE)
AS
BEGIN
    SELECT list_price
    INTO price
    FROM products
    WHERE product_id = id;
EXCEPTION
    WHEN no_data_found THEN
        price := 0;
    WHEN OTHERS THEN
        price := 0;
        dbms_output.put_line('Unexpected Error');
END;

DECLARE
    price NUMBER;
BEGIN
    find_product(9999, price);
    dbms_output.put_line(price);
END;

-- Question 3
-- This procedure has an input parameter to receive the customer ID and an output
-- parameter named new_order_id.
-- To add a new order for the given customer ID, you need to generate the new order Id. To
-- calculate the new order Id, find the maximum order ID in the orders table and increase it by
-- 1.
-- This procedure inserts the following values in the orders table:
-- new_order_id
-- customer_id (input parameter)
-- 'Shipped' (The value for the order status)
-- 56 (The sales person ID)
-- sysdate (order date which is the current date)
-- Q3 Solution
CREATE OR REPLACE PROCEDURE add_order(customer IN NUMBER, next_order OUT NUMBER)
AS
BEGIN
    SELECT MAX(order_id)
    INTO next_order
    FROM orders;
    IF next_order IS NOT NULL THEN
        next_order := next_order + 1;
    ELSE
        next_order := 0;
    END IF;
    INSERT INTO orders(order_id, customer_id, status, salesman_id, order_date)
    VALUES (next_order, customer, 'Shipped', 56, SYSDATE);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Unexpected Error');
END;

DECLARE
    new_order_id NUMBER;
BEGIN
    add_order(10, new_order_id);
    dbms_output.put_line(new_order_id);
END;

-- Question 4
-- This procedure has five IN parameters. It stores the values of these parameters to the table
-- order_items.
-- Q4 Solution
CREATE OR REPLACE PROCEDURE add_order_item(provided_order_id IN order_items.ORDER_ID%TYPE,
                                           provided_item_id IN order_items.ITEM_ID%TYPE,
                                           provided_product_id IN order_items.PRODUCT_ID%TYPE,
                                           provided_quantity IN order_items.QUANTITY%TYPE,
                                           price IN order_items.UNIT_PRICE%TYPE)
AS
BEGIN
    INSERT INTO order_items
        (order_id, item_id, product_id, quantity, unit_price)
    VALUES (provided_order_id, provided_item_id, provided_product_id, provided_quantity, price);
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Unexpected Error');
END;

BEGIN
    add_order_item(105, 7, 111, 11, 121212);
END;