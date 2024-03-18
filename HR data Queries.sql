/*Creating database*/
CREATE DATABASE hr_db;

/*Using that Database*/
USE hr_db;

/*Showing list of tables from the selected database*/
SHOW TABLES FROM hr_db;

/*Show the list of columns and it's attributes from the table*/
SHOW COLUMNS from hr;
DESCRIBE hr;

					/*Data Cleaning*/
/*ID column name needs correction so we are going to provide new column name*/
ALTER TABLE hr
RENAME COLUMN ï»¿id to emp_id;

/*Going to change the data type emp_id column to varchar data type*/
ALTER TABLE hr
MODIFY COLUMN emp_id VARCHAR(20);

/*Before updating the records or fields in the table we need to remove the security from the database*/
SET sql_safe_updates = 0;

/*Going to update the format of the birthdate column*/
UPDATE hr
SET birthdate = CASE
				WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
                WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
                ELSE NULL
                END;
                
/*Going to change the datatype of the birthdate column to DATE data type*/
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

/*Going to update the format of the hire_date column*/
UPDATE hr
SET hire_date = CASE
				WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
                WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
                ELSE NULL
                END;

/*Going to change the datatype of the hire_date column to DATE data type*/
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

/*Going to update the format of the termdate column*/
UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

/*Going to update NULL in the emply spaces in the termdate column*/
UPDATE hr
SET termdate = NULL
WHERE termdate = '';

/*Going to change the data type of the termdate column to DATE data type*/
ALTER TABLE hr
MODIFY COLUMN termdate DATE;

/*Add a age column in the hr table*/
ALTER TABLE hr
ADD COLUMN age int;

/*Update the age column by calculating the age of each employees*/
UPDATE hr
SET age = timestampdiff(YEAR,birthdate,curdate());

/*After updating the records or fields in the table we need to add the security to the database*/
SET sql_safe_updates = 1;

									/*Data Analysis*/
-- QUESTIONS

-- Count of Total Employees
SELECT COUNT(*) AS "Total Employees"  FROM hr
WHERE termdate IS NULL;

-- Checking the minimum and maximum age of employees in the data*/
SELECT MIN(age) AS "Minimum Age", MAX(age) AS "Maximum Age" FROM hr;


-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY race;

-- 3. What is the age distribution of employees in the company?
SELECT CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
        END AS Age_Group, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY Age_Group
ORDER BY Age_Group;

SELECT CASE
		WHEN age>=18 AND age<=24 THEN '18-24'
        WHEN age>=25 AND age<=34 THEN '25-34'
        WHEN age>=35 AND age<=44 THEN '35-44'
        WHEN age>=45 AND age<=54 THEN '45-54'
        WHEN age>=55 AND age<=64 THEN '55-64'
        ELSE '65+'
        END AS Age_Group, gender, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY Age_Group, gender
ORDER BY Age_Group;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(YEAR(termdate)-YEAR(hire_date)),0) AS "Average Length of Employment" FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate();

-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, jobtitle, gender, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle;

SELECT department, gender, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY jobtitle;

-- 8. Which department has the highest turnover rate / termination rate?
SELECT department, COUNT(*) AS Total_Count,
COUNT(CASE
		WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
        END) AS Termination_Count, 
ROUND((COUNT(CASE
		WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
        END) / COUNT(*))*100,2) AS Termination_rate FROM hr
GROUP BY department
ORDER BY Termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?
SELECT location_state, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY location_state;

SELECT location_city, COUNT(*) AS "Employee Count" FROM hr
WHERE termdate IS NULL
GROUP BY location_city;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT year, hires, terminations, hires-terminations AS net_change, ROUND(((hires-terminations)/hires)*100,2) AS net_change_percentage
FROM (SELECT YEAR(hire_date) AS year, COUNT(*) AS hires, COUNT(CASE
																WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1
                                                                END) AS terminations FROM hr
		GROUP BY YEAR(hire_date)) AS sub_query
ORDER BY year;

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(YEAR(termdate)-YEAR(hire_date)),0) AS "Average Tenure" FROM hr
WHERE termdate IS NOT NULL AND termdate <= curdate()
GROUP BY department;