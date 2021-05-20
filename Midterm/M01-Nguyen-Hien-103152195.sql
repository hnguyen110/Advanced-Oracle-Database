-- ***********************
-- Name: Hien Dao The Nguyen
-- ID: 103 152 195
-- Date: Feb - 25 - 2021
-- Purpose: Midterm 01 DBS311NFF
-- ***********************

-- Q1 Question
-- Write a query which shows the common last names of any individuals in both
-- tables. Make sure you ignore case (Smith=SMITH=smith). Make sure duplicates
-- are removed. Alphabetically order the results.
-- Q1 Solution
SELECT INITCAP(lname) AS "Last Name"
FROM (
         SELECT lname, COUNT(*) AS count
         FROM (
                  SELECT DISTINCT LOWER(lastname) AS lname
                  FROM employee
                  UNION ALL
                  SELECT DISTINCT LOWER(name) AS lname
                  FROM staff
              )
         GROUP BY lname
     )
WHERE count != 1
ORDER BY lname;

-- Q2 Question
-- Write a query which shows the employee IDs that are unique to the employee
-- table. Order the employee IDs in descending order. An employee ID Is the same
-- in both tables if the integer value of the ID matches.
-- Q2 Solution
SELECT empno AS "Employee ID"
FROM employee
MINUS
SELECT empno
FROM employee
         INNER JOIN staff ON empno = id
ORDER BY "Employee ID" DESC;

-- Q3 Question
-- We want to add a new column to the employee table. We want to provide a new
-- column with a more complete phone number. Right now the PHONENO column
-- only shows the last 4 digits.
-- We want a new column which is called PHONE and consists of ###-###-####. The
-- last 4-digits are already in the PHONENO column. The first three digits should be
-- 416 and the next three should be 123.
-- To improve clarity in the table, we also want to rename the PHONENO column to
-- PHONEEXT.
-- Show all the commands used to accomplish this, then, select all data for
-- employees who have the last name of 'smith' (case insensitive).
-- Q3 Solution
SELECT *
FROM employee;

ALTER TABLE employee
    ADD phone VARCHAR2(13);

UPDATE employee
SET employee.phone = '416-123-' || employee.phoneno;

ALTER TABLE employee
    RENAME COLUMN phoneno TO phoneext;

SELECT empno                            AS "Employee ID",
       firstname                        AS "First Name",
       midinit                          AS "Middle Name",
       lastname                         AS "Last Name",
       workdept                         AS "Department",
       phoneext                         AS "Phone Ext",
       TO_CHAR(hiredate, 'DD-MON-YYYY') AS "Hire Date",
       job                              AS "Position",
       edlevel                          AS "Education Level",
       sex                              AS "Sex",
       birthdate                        AS "Birth Date",
       salary                           AS "Salary",
       bonus                            AS "Bonus",
       comm                             AS "Commission",
       phone                            AS "Phone Number"
FROM employee
WHERE LOWER(lastname) = 'smith';

COMMIT;

-- Q4
-- Show a list of employee id, names, department, years and job of any employee in
-- the staff table who makes a total amount more than their manager or has more
-- years of service than their manager.
-- Make sure to include both salary and commission when calculating the total
-- amount someone makes.
-- Exclude staff in department 10 from the query.
-- Order the results by department then name
-- Q4 Solution
SELECT emp_id           AS "Employee ID",
       emp_name         AS "Employee Name",
       emp_dept         AS "Employee Department",
       NVL(emp_year, 0) AS "Years Of Empployment",
       emp_job          AS "Position"
FROM (
         SELECT *
         FROM (
                  SELECT id     AS manager_id,
                         name   AS manager_name,
                         dept   AS manager_dept,
                         job    AS manager_job,
                         years  AS manager_years,
                         salary AS manager_salary,
                         comm   AS manager_comm
                  FROM (
                           SELECT *
                           FROM staff
                           WHERE dept != 10
                       )
                  WHERE LOWER(job) = 'mgr'
              )
                  INNER JOIN
              (
                  SELECT id     AS emp_id,
                         name   AS emp_name,
                         dept   AS emp_dept,
                         job    AS emp_job,
                         years  AS emp_year,
                         salary AS emp_salary,
                         comm   AS emp_comm
                  FROM staff
                  WHERE dept != 10
                  MINUS
                  SELECT *
                  FROM (
                           SELECT *
                           FROM staff
                           WHERE dept != 10
                       )
                  WHERE LOWER(job) = 'mgr'
              )
              ON emp_dept = manager_dept
     )
WHERE emp_year > manager_years
   OR (emp_salary + emp_comm) > (manager_salary + manager_comm)
ORDER BY emp_dept, emp_name;

-- Q5 Question
-- Show a list of all employees, their department and their jobs, from the staff table,
-- that are in the same department as 'Graham'
-- Order by name alphabetically. Exclude 'Graham' from the result set.
-- Q5 Solution
SELECT id                                     AS "ID",
       name                                   AS "Name",
       dept                                   AS "Department",
       job                                    AS "Position",
       NVL(years, 0)                          AS "Years Of Employment",
       TO_CHAR(salary, '$999,999,999,999.99') AS "Salary",
       NVL(comm, 0)                           AS "Commission"
FROM (
         SELECT *
         FROM staff
         WHERE dept = (SELECT dept FROM staff WHERE LOWER(name) = 'graham')
     )
WHERE LOWER(name) != 'graham'
ORDER BY name;

-- Q6 Question
-- Show the list of employee names, job and variable pay, from the employee table,
-- who have the lowest and highest variable pay (includes commission and bonus)
-- by job category.
-- The name should be formatted: lastname, firstname with the first character
-- capitalized and all other characters in lower case. (ie: King, Les). The title of this
-- column should be “Name”.
-- The variable pay column should be called “Variable Pay”.
-- Order the results by highest variable pay to lowest variable pay.
-- Q6 Solution
SELECT INITCAP(firstname) || ', ' || INITCAP(lastname) AS "Name",
       INITCAP(job)                                    AS "Job",
       TO_CHAR(bonus + comm, '$999,999,999,999.99')    AS "Variable Pay"
FROM employee
WHERE (bonus + comm) IN (SELECT MAX(bonus + comm) FROM employee GROUP BY job)
   OR (bonus + comm) IN (SELECT (MIN(bonus + comm)) FROM employee GROUP BY job)
ORDER BY "Variable Pay" DESC;

-- Q7 Question
-- Using the staff table, show all employees who have an 'il' in their name - or - their
-- name ends with an 's'. Make sure your query is case insensitive.
-- You just need to display the name of the employee in your output. Order them
-- alphabetically.
-- Q7 Solution
SELECT name
FROM staff
WHERE LOWER(name) LIKE '%il%'
   OR LOWER(name) LIKE '%s'
ORDER BY name;

-- Q8 Question
-- Using the staff table, display the employee name, job, salary and commission for
-- all employees with a salary less than the salary of all people with a manager job or
-- full compensation less than the full compensation of all the people with a sales
-- job.
-- Full compensation is the sum of both salary and commission.
-- Exclude people with a sales job from the output.
-- Q8 Solution
SELECT name                                         AS "Employee Name",
       job                                          AS "Job",
       TO_CHAR(salary, '$999,999,999,999')          AS "Salary",
       TO_CHAR(NVL(comm, 0), '$999,999,999,999.99') AS "Commission"
FROM (
         SELECT *
         FROM staff
         WHERE LOWER(job) != 'sales'
     )
WHERE salary < ALL (
    SELECT salary
    FROM staff
    WHERE LOWER(job) = 'mgr'
)
   OR (salary + comm) < ALL (
    SELECT salary + comm
    FROM staff
    WHERE LOWER(job) = 'sales'
)
ORDER BY name;

-- Q9 Question
-- From the employee table, calculate the average compensation for each job
-- category where the employee has 16 or more years of education.
-- Display the job and average compensation in the result set.
-- Exclude people who are clerks
-- Make sure to include salary, commission and bonus when looking at employee
-- compensation
-- Order the output by the average salary in ascending order.
-- Q9 Solution
SELECT TO_CHAR(AVG(salary + bonus + comm), '$999,999,999,999.99') AS "Average Compensation",
       job                                                        AS "Job"
FROM employee
WHERE edlevel >= 16
  AND LOWER(job) != 'clerk'
GROUP BY job
ORDER BY "Average Compensation";

-- Q10 Question
-- Show the first name, last name, hire date, birth date, education level and years of
-- service for employees who are both in the staff table and the employee table
-- An individual is the same individual if a case insensitive comparison of last name
-- matches.
-- Q10 Solution
SELECT firstname                        AS "First Name",
       lastname                         AS "Last Name",
       TO_CHAR(hiredate, 'DD-MON-YYYY') AS "Hire Date",
       edlevel                          AS "Education Level",
       NVL(years, 0)                    AS "Years Of Employment"
FROM employee
         INNER JOIN staff ON LOWER(lastname) = LOWER(name);