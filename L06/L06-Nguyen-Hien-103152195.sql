-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103 152 195
-- Date: Feb - 24 - 2021
-- Purpose: Lab 6 DBS311
-- ***********************

-- Question 1
-- Write a store procedure that gets an integer number n and calculates and displays its factorial.
-- Q1 Solution
CREATE OR REPLACE PROCEDURE factorial(num IN NUMBER) AS
    counter NUMBER;
    result  NUMBER := 1;
BEGIN
    FOR counter IN 1..num
        LOOP
            result := result * counter;
        END LOOP;
    dbms_output.put(num || '! = fact(' || num || ')');
    IF (num != 0) THEN
        dbms_output.put(' = ');
    END IF;
    FOR counter IN 0..num - 1
        LOOP
            IF (counter != 0) THEN
                dbms_output.put(' * ');
            END IF;
            dbms_output.put(num - counter);
        END LOOP;
    dbms_output.put_line(' = ' || result);

EXCEPTION
    WHEN OTHERS
        THEN
            dbms_output.put_line('The server can not process your last request, please try again');
END;

BEGIN
    factorial(3);
END;

-- Question 2
-- The company wants to calculate the employees’ annual salary:
-- The first year of employment, the amount of salary is the base salary which is $10,000.
-- Every year after that, the salary increases by 5%.
-- Write a stored procedure named calculate_salary which gets an employee ID and for that
-- employee calculates the salary based on the number of years the employee has been working
-- in the company. (Use a loop construct to calculate the salary).
-- The procedure calculates and prints the salary.
-- Sample output:
-- First Name: first_name
-- Last Name: last_name
-- Salary: $9999,99
-- If the employee does not exists, the procedure displays a proper message.
-- Q2 Solution
CREATE OR REPLACE PROCEDURE calculate_salary(employee_no IN NUMBER) AS
    salary             NUMBER(9, 2) := 10000;
    base_salary        NUMBER(9, 2) := 10000;
    first_name         VARCHAR2(255 BYTE);
    last_name          VARCHAR2(255 BYTE);
    rate               NUMBER       := 0.05;
    year_of_employment NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date) / 12),
           first_name,
           last_name
    INTO year_of_employment, first_name, last_name
    FROM employees
    WHERE employee_id = employee_no;

    FOR counter IN 1..year_of_employment
        LOOP
            salary := salary + base_salary * rate;
        END LOOP;
    dbms_output.put_line('First Name: ' || first_name);
    dbms_output.put_line('Last Name: ' || last_name);
    dbms_output.put_line('Salary: $' || salary);
EXCEPTION
    WHEN no_data_found
        THEN
            dbms_output.put_line('The server can not find employee with id of ' || employee_no);
    WHEN OTHERS
        THEN
            dbms_output.put_line('The server can not process your last request, please try again');
END;

BEGIN
    calculate_salary(100);
END;

-- Question 3
-- Write a stored procedure named warehouses_report to print the warehouse ID, warehouse
-- name, and the city where the warehouse is located in the following format for all warehouses:
-- Warehouse ID:
-- Warehouse name:
-- City:
-- State:
-- If the value of state does not exist (null), display “no state”.
-- The value of warehouse ID ranges from 1 to 9.
-- You can use a loop to find and display the information of each warehouse inside the loop.
-- (Use a loop construct to answer this question. Do not use cursors.)
-- Q3 Solution
CREATE OR REPLACE PROCEDURE warehouses_report AS
    warehouse_id   warehouses.WAREHOUSE_ID%TYPE;
    warehouse_name warehouses.WAREHOUSE_NAME%TYPE;
    city           locations.CITY%TYPE ;
    state          locations.STATE%TYPE;
BEGIN
    FOR counter IN 1..9
        LOOP
            SELECT warehouse_id, warehouse_name, city, state
            INTO warehouse_id, warehouse_name, city, state
            FROM warehouses
                     LEFT JOIN locations
                               ON warehouses.location_id = locations.location_id
            WHERE warehouse_id = counter;

            dbms_output.put_line('Warehouse ID: ' || warehouse_id);
            dbms_output.put_line('Warehouse name: ' || warehouse_name);
            dbms_output.put_line('City: ' || city);
            dbms_output.put_line('State: ' || NVL(state, 'no state'));
        END LOOP;
EXCEPTION
    WHEN too_many_rows THEN
        dbms_output.put_line('The query return too many results, please check your query and try again');
    WHEN OTHERS THEN
        dbms_output.put_line('The server can not process your last request, please try again');
END;

BEGIN
    warehouses_report();
END;