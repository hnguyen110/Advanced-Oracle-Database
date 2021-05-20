-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103 152 195
-- Date: 04 - 23 - 2021
-- Purpose: Final Part A DBS311NFF
-- ***********************

-- Question 1
-- Write a query which lists the employee (from EMPLOYEE table) with the highest total compensation (includes SALARY, BONUS and COMMISSION) by department and job type.
-- The result set should have department, job type, employee number, total compensation.
-- The result set should be ordered by department, then, job type within the department.
-- Q1 Solution
SELECT "Department",
       "Occupation",
       "Employee Number",
       TO_CHAR("Compensation", '$999,999,999,999.99') AS "Compensation"
FROM (
         SELECT workdept                AS "Department",
                job                     AS "Occupation",
                empno                   AS "Employee Number",
                (salary + bonus + comm) AS "Compensation"
         FROM employee
     )
WHERE "Compensation" IN (
    SELECT compensation
    FROM (
             SELECT MAX(salary + bonus + comm) AS compensation
             FROM employee
             GROUP BY workdept, job
         )
)
ORDER BY "Department", "Occupation";

-- Question 2
-- Write a query which shows the complete list of last names from both the EMPLOYEE table and STAFF table. Make sure your query is case insensitive (ie SMITH = Smith = smith).
-- Make sure names are not duplicated. We only want to see each name once in the result set.
-- Display the names with the initial character as a capital (ie: Smith, Jones, etc).
-- Output should be in ascending order (alphabetical order)
-- Q2 Solution
SELECT INITCAP(lastname) AS "Last Name"
FROM (
         SELECT LOWER(lastname) AS lastname
         FROM employee
         UNION
         SELECT LOWER(name) AS lastname
         FROM staff
     )
ORDER BY LOWER("Last Name");

-- Question 3
-- Write a query which shows where we have two employees assigned to the same employee number, when looking across both EMPLOYEE table and STAFF table.
-- The output should be ordered first by employee number, then by last name
-- Q3 Solution
SELECT id       AS "Employee Number",
       lastname AS "Last Name"
FROM (
         SELECT TO_NUMBER(empno) AS id, INITCAP(lastname) AS lastname
         FROM employee
         UNION
         SELECT id, INITCAP(name) AS lastname
         FROM staff
     )
WHERE id IN (
    SELECT TO_NUMBER(empno) AS id
    FROM employee
    INTERSECT
    SELECT id
    FROM staff
)
ORDER BY id, lastname;

-- Question 4
-- Write a query which lists all employees across both the STAFF and EMPLOYEE table, which have an ‘oo’ OR a ‘z’ in their last name.
-- This query should be case insensitive, meaning both a ‘Z’ and a ‘z’ count for the condition, as an example.
-- The output should be ordered by lastname.
-- Q4 Solution
SELECT INITCAP(lastname) AS "Last Name"
FROM (SELECT LOWER(lastname) AS lastname
      FROM employee
      UNION ALL
      SELECT LOWER(name) AS lastname
      FROM staff)
WHERE lastname LIKE '%z%'
   OR lastname LIKE '%oo%'
ORDER BY LOWER("Last Name");

-- Question 5
-- Write a query which looks at the EMPLOYEE table and, for each department, compares the
-- manager’s total compensation (SALARY, BONUS and COMMISSION) to the top paid
-- employee’s total compensation and displays output if the top paid employee in that
-- department makes within $10,000 in total compensation as compared to their manager
-- The output should include department, manager’s total compensation and top paid employee’s total compensation
-- - If a department has no non-managers – OR – has no manager, assume total compensation is 0
-- Q5 Solution
SELECT department                                            AS "Department",
       TO_CHAR(manager_compensation, '$999,999,999,999.99')  AS "Manager Compensation",
       TO_CHAR(employee_compensation, '$999,999,999,999.99') AS "Employee Compensation"
FROM (
         SELECT department,
                COALESCE(manager_compensation, 0)  AS manager_compensation,
                COALESCE(employee_compensation, 0) AS employee_compensation
         FROM (
                  SELECT DISTINCT workdept AS department
                  FROM employee
              )
                  LEFT JOIN (
             SELECT workdept              AS manager_department,
                    salary + bonus + comm AS manager_compensation
             FROM employee
             WHERE LOWER(job) = 'manager'
         ) ON department = manager_department

                  LEFT JOIN (
             SELECT employee_department,
                    MAX(employee_compensation) AS employee_compensation
             FROM (
                      SELECT workdept              AS employee_department,
                             salary + bonus + comm AS employee_compensation
                      FROM employee
                      WHERE LOWER(job) != 'manager'
                  )
             GROUP BY employee_department
         ) ON department = employee_department
         WHERE manager_compensation - employee_compensation BETWEEN 0 AND 10000
     );

-- Question 6
-- Write a query which looks across both the EMPLOYEE and STAFF table and returns the total “variable pay” (COMMISSION + BONUS) for each employee.
-- If an employee does not make either, the output should be 0
-- The output should include the employee’s last name and total variable pay
-- The output should be ordered by a case insensitive view of their last name in alphabetical order
-- Q6 Solution
SELECT lastname                                     AS "Last Name",
       TO_CHAR(variable_pay, '$999,999,999,999.99') AS "Variable Pay"
FROM (
         SELECT INITCAP(lastname)                      AS lastname,
                COALESCE(bonus, 0) + COALESCE(comm, 0) AS variable_pay
         FROM employee
         UNION ALL
         SELECT INITCAP(name)     AS lastname,
                COALESCE(comm, 0) AS variable_pay
         FROM staff
         ORDER BY lastname
     );

-- Question 7
-- Write a stored procedure for the EMPLOYEE table which takes, as input, an employee number and a rating of either 1, 2 or 3.
-- The stored procedure should perform the following changes:
-- If the employee was rated a 1 – they receive a $10,000 salary increase, additional $300 in bonus and an additional 5% of salary as commission
-- If the employee was rated a 2 – they receive a $5,000 salary increase, additional $200 in  bonus and an additional 2% of salary as commission
-- If the employee was rated a 3 – they receive a $2,000 salary increase with no change to their variable pay
-- Make sure you handle two types of errors: (1) A non-existent employee – and – (2) A non valid rating. Both should have an appropriate message.
-- The stored procedure should return the employee number, previous compensation and new compensation (all three compensation components showed separately)
-- EMP OLD SALARY OLD BONUS OLD COMM NEW SALARY NEW BONUS NEW COMM
-- Demonstrate that your stored procedure works correctly by running it 5 times: Three times with a valid employee number and a 1 rating, 2 rating and 3 rating. Once with an invalid employee number. Once with an invalid rating level.
-- Q7 Solution
CREATE OR REPLACE PROCEDURE update_compensation(id IN employee.EMPNO%TYPE, rating IN NUMBER) AS
    employee_id    employee.EMPNO%TYPE;
    old_salary     employee.SALARY%TYPE;
    old_bonus      employee.BONUS%TYPE;
    old_commission employee.COMM%TYPE;
    new_salary     employee.SALARY%TYPE;
    new_bonus      employee.BONUS%TYPE;
    new_commission employee.COMM%TYPE;
    invalid_rating EXCEPTION;
BEGIN
    SELECT empno, COALESCE(salary, 0), COALESCE(bonus, 0), COALESCE(comm, 0)
    INTO employee_id, old_salary, old_bonus, old_commission
    FROM employee
    WHERE TO_NUMBER(empno) = id;

    IF rating = 1 THEN
        new_salary := old_salary + 10000;
        new_bonus := old_bonus + 300;
        new_commission := old_commission + old_salary * 2 / 100;
    ELSIF rating = 2 THEN
        new_salary := old_salary + 5000;
        new_bonus := old_bonus + 200;
        new_commission := old_commission + old_salary * 2 / 100;
    ELSIF rating = 3 THEN
        new_salary := old_salary + 10000;
        new_bonus := old_bonus + 300;
    ELSE
        RAISE invalid_rating;
    END IF;

    UPDATE employee SET salary = new_salary, bonus = new_bonus, comm = new_commission WHERE empno = employee_id;

    dbms_output.put_line('Employee ID ' || TO_CHAR(employee_id));
    dbms_output.put_line('Old Salary ' || TO_CHAR(old_salary));
    dbms_output.put_line('Old Bonus ' || TO_CHAR(old_bonus));
    dbms_output.put_line('Old Commission ' || TO_CHAR(old_commission));
    dbms_output.put_line('New Salary ' || TO_CHAR(new_salary));
    dbms_output.put_line('New Bonus ' || TO_CHAR(new_bonus));
    dbms_output.put_line('New Commission ' || TO_CHAR(new_commission));
EXCEPTION
    WHEN invalid_rating
        THEN
            dbms_output.put_line('Invalid rating number');
            dbms_output.put_line('Rating number must be between 1 and 3');
    WHEN no_data_found
        THEN
            dbms_output.put_line('Invalid Employee ID');
            dbms_output.put_line('Employee record can not be found');
    WHEN OTHERS
        THEN
            dbms_output.put_line('Error Code: ' + SQLCODE);
            dbms_output.put_line('Error Message: ' + SQLERRM);
END;

BEGIN
    update_compensation(10, 1);
    update_compensation(10, 2);
    update_compensation(10, 3);
    update_compensation(1000, 1);
    update_compensation(10, 4);
END;

-- Question 8
-- Write a stored procedure for the EMPLOYEE table which takes employee number and
-- education level upgrade as input - and - increases the education level of the employee based
-- on the input. Valid input is:
-- “H” (for high school diploma) – and – this will update the edlevel to 16
-- “C” (for college diploma) – and – this will update the edlevel to 19
-- “U” (for university degree) – and – this will update the edlevel to 20
-- “M” (for masters) – and – this will update the edlevel to 23
-- “P” (for PhD) – and – this will update the edlevel to 25
-- Make sure you handle the error condition of incorrect education level input – and – nonexistent employee number
-- Also make sure you never reduce the existing education level of the employee. They can only stay the same or go up.
-- A message should be provided for all three error cases.
-- When no errors occur, the output should look like:
-- EMP OLD EDUCATION NEW EDUCATION
-- Q8 Solution
CREATE OR REPLACE PROCEDURE update_education_level(id IN employee.EMPNO%TYPE, level IN CHAR) AS
    employee_id   employee.EMPNO%TYPE;
    old_education employee.EDLEVEL%TYPE;
    new_education employee.EDLEVEL%TYPE;
    unexpected_level EXCEPTION;
    low_level EXCEPTION;
BEGIN
    SELECT empno, edlevel
    INTO employee_id, old_education
    FROM employee
    WHERE TO_NUMBER(empno) = id;

    IF level = 'H' THEN
        IF old_education < 16 THEN
            new_education := 16;
        ELSE
            RAISE low_level;
        END IF;
    ELSIF level = 'C' THEN
        IF old_education < 19 THEN
            new_education := 19;
        ELSE
            RAISE low_level;
        END IF;
    ELSIF level = 'U' THEN
        IF old_education < 20 THEN
            new_education := 20;
        ELSE
            RAISE low_level;
        END IF;
    ELSIF level = 'M' THEN
        IF old_education < 23 THEN
            new_education := 23;
        ELSE
            RAISE low_level;
        END IF;
    ELSIF level = 'P' THEN
        IF old_education < 25 THEN
            new_education := 25;
        ELSE
            RAISE low_level;
        END IF;
    ELSE
        RAISE unexpected_level;
    END IF;

    UPDATE employee SET edlevel = new_education WHERE empno = employee_id;

    dbms_output.put_line('Employee ID ' || TO_CHAR(employee_id));
    dbms_output.put_line('Old Education ' || TO_CHAR(old_education));
    dbms_output.put_line('New Education ' || TO_CHAR(new_education));

EXCEPTION
    WHEN unexpected_level
        THEN
            dbms_output.put_line('Invalid educational level');
            dbms_output.put_line('Educational level is not expected');
            dbms_output.put_line('Accepted educational level are: ');
            dbms_output.put_line('H - High School Diploma');
            dbms_output.put_line('C - College Diploma');
            dbms_output.put_line('U - University Degree');
            dbms_output.put_line('M - Master');
            dbms_output.put_line('P - PhD');
    WHEN low_level
        THEN
            dbms_output.put_line('Invalid educational level');
            dbms_output.put_line('Given educational level is lower than current level');
    WHEN no_data_found
        THEN
            dbms_output.put_line('Invalid Employee ID');
            dbms_output.put_line('Employee record can not be found');
    WHEN OTHERS
        THEN
            dbms_output.put_line('Error Code: ' + SQLCODE);
            dbms_output.put_line('Error Message: ' + SQLERRM);
END;

BEGIN
    update_education_level(100, 'H');
    update_education_level(100, 'C');
    update_education_level(100, 'U');
    update_education_level(100, 'M');
    update_education_level(100, 'P');
    update_education_level(100, 'Z');
    update_education_level(1000, 'P');
    update_education_level(10, 'H');
END;

-- Question 9
-- Write a function called PHONE which takes an employee number as input and displays a full phone number for that employee, using the PHONENO value as part of the function.
-- PHONE(100) should run for employee 100
-- This function should convert the existing PHONENO value into a full phone number which looks like “(416) 123-xxxx” where xxxx is the existing PHONENO value.
-- This function will return the full phone number.
-- Q9 Solution
CREATE OR REPLACE FUNCTION phone(id IN employee.EMPNO%TYPE)
    RETURN CHAR
AS
    phone_number employee.PHONENO%TYPE;
BEGIN
    SELECT phoneno
    INTO phone_number
    FROM employee
    WHERE TO_NUMBER(empno) = id;
    RETURN '(416) 123-' || phone_number;
END;

-- Question 10
-- Execute an UPDATE command which adds a new column to your EMPLOYEE table called
-- PHONENUM as CHAR(14)
-- Write a stored procedure which calls your PHONE function.
-- This stored procedure should go through a loop for all records where the department number begins with a E and updates the value of PHONENUM with the output of the PHONE function
-- For each row, as it is updated the following should be printed
-- DEPT EMP PHONENO PHONENUM
-- Q10 Solution
ALTER TABLE employee
    ADD phonenum CHAR(14);

CREATE OR REPLACE PROCEDURE update_phone_number AS
    department    employee.WORKDEPT%TYPE;
    employee_id   employee.EMPNO%TYPE;
    phone_no      employee.PHONENO%TYPE;
    full_phone_no employee.PHONENUM%TYPE;
BEGIN
    FOR each IN (SELECT empno AS id, phone(empno) AS phone_number FROM employee WHERE workdept LIKE 'E%')
        LOOP
            UPDATE employee
            SET phonenum = each.phone_number
            WHERE empno = each.id;
        END LOOP;

    FOR each IN (SELECT empno AS id FROM employee WHERE workdept LIKE 'E%')
        LOOP
            SELECT workdept, empno, phoneno, phonenum
            INTO department, employee_id, phone_no, full_phone_no
            FROM employee
            WHERE empno = each.id;

            dbms_output.put_line('Department ' || department);
            dbms_output.put_line('Employee ID ' || employee_id);
            dbms_output.put_line('Phone Number ' || phone_no);
            dbms_output.put_line('Full Phone Number ' || full_phone_no);
        END LOOP;

EXCEPTION
    WHEN
        OTHERS THEN
        dbms_output.put_line('Error Code: ' + SQLCODE);
        dbms_output.put_line('Error Message: ' + SQLERRM);
END;

BEGIN
    update_phone_number();
END;

SELECT workdept,
       phoneno,
       phonenum
FROM employee;