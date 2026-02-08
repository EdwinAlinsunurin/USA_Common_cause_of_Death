-- Load Table as column as text category becuase cannot load all file properly(Truncated)
SHOW DATABASES;
USE mydata;
SHOW TABLES;
RENAME TABLE `lcd-table` TO lcd_table;
DESC lcd_table;

-- CLEANING
-- Rename Column Replace spaces by "_" use backticks to enclose the indetifiers
ALTER TABLE lcd_table RENAME COLUMN `Age Group` TO Age_Group;
ALTER TABLE lcd_table RENAME COLUMN `Cause Category` TO Cause_Category;
ALTER TABLE lcd_table RENAME COLUMN `Crude Rate` TO Crude_Rate;

-- Create another table for update 
CREATE TABLE lcd_table2 LIKE lcd_table;
INSERT INTO lcd_table2 SELECT * FROM lcd_table;
SELECT * FROM lcd_table2;

-- Remove Unwanted row on Age_Group Column 
SELECT * FROM lcd_table2;
SELECT Age_Group FROM lcd_table2
GROUP BY Age_Group;

SELECT * FROM lcd_table2
WHERE length(Age_Group) >9;

DELETE FROM lcd_table2
WHERE length(Age_Group) >9;
SELECT * FROM lcd_table2;

-- re Modify column category Rank from Text to INT
-- use backticks becuase Rank column name also have function on mySQL
SELECT `Rank` FROM lcd_table2
GROUP BY `Rank`;
ALTER TABLE lcd_table2
MODIFY COLUMN `Rank` INT;

-- remove comma in Deaths column and convert category to INT
UPDATE lcd_table2
SET Deaths = REPLACE(Deaths, ',','');
ALTER TABLE lcd_table2
MODIFY COLUMN Deaths INT;

-- convert category column Crude rate from text to decimal
ALTER TABLE lcd_table2
MODIFY COLUMN Crude_Rate DECIMAL(10,1);

-- Remove %  and change column Percentage to decimal
SELECT * FROM lcd_table2;
UPDATE lcd_table2
SET Percentage =REPLACE(Percentage,'%','');
ALTER TABLE lcd_table2
MODIFY COLUMN Percentage DECIMAL(10,1);

-- Make another column and ALIAS as Age_Range
SELECT Age_Group FROM lcd_table2
GROUP BY Age_Group;

ALTER TABLE lcd_table2
ADD COLUMN Age_Range VARCHAR(50);

SELECT * ,
CASE
	WHEN Age_Group = '<1' THEN 'less 1 yrs old'
    WHEN Age_Group = '1-4' THEN '1 to 4 yrs old'
	WHEN Age_Group = '5-9' THEN '5 to 9 yrs old'
    WHEN Age_Group = '10-14' THEN '10 to 14 yrs old'
    WHEN Age_Group = '15-24' THEN '15 to 24 yrs old'
    WHEN Age_Group = '25-24' THEN '25 to 34 yrs old'
    WHEN Age_Group = '35-44' THEN '35 to 44 yrs old'
	WHEN Age_Group = '45-54' THEN '45 to 54 yrs old'
    WHEN Age_Group = '55-64' THEN '55 to 64 yrs old'
    WHEN Age_Group = '65+' THEN 'above 65 yrs old'
	ELSE 'All Ages'
END AS Age_Range
FROM lcd_table2;

UPDATE lcd_table2
SET Age_Range = CASE
	WHEN Age_Group = '<1' THEN 'less 1 yrs old'
    WHEN Age_Group = '1-4' THEN '1 to 4 yrs old'
	WHEN Age_Group = '5-9' THEN '5 to 9 yrs old'
    WHEN Age_Group = '10-14' THEN '10 to 14 yrs old'
    WHEN Age_Group = '15-24' THEN '15 to 24 yrs old'
    WHEN Age_Group = '25-34' THEN '25 to 34 yrs old'
    WHEN Age_Group = '35-44' THEN '35 to 44 yrs old'
	WHEN Age_Group = '45-54' THEN '45 to 54 yrs old'
    WHEN Age_Group = '55-64' THEN '55 to 64 yrs old'
    WHEN Age_Group = '65+' THEN 'above 65 yrs old'
	ELSE 'All Ages'
END;


--  Analyze data
-- Top 5 Causes of Deaths
Select Cause_Category, SUM(Deaths) AS Total_Deaths FROM lcd_table2
GROUP BY Cause_Category
ORDER BY Total_Deaths DESC LIMIT 5;

-- Total Deaths by Age Range
Select Age_Range, SUM(Deaths) AS Total_Deaths FROM lcd_table2
GROUP BY Age_Range
ORDER BY Total_Deaths DESC;

-- Rank1 Cause of Defect by Age Range
SELECT * FROM lcd_table2
WHERE `Rank`=1
ORDER BY Cause_Category;

-- High Death percentage by cause category and Age Range
SELECT Cause_Category, Age_Range, Percentage FROM lcd_table2
ORDER BY Percentage DESC;

-- Crude Rate approximate deaths per 1000 population in cause category
SELECT Cause_Category, AVG(Crude_Rate) AS Death_per1000 FROM lcd_table2
GROUP BY Cause_Category
ORDER BY Death_per1000 DESC;

-- Overall Statistic by Age Range
SELECT Cause_Category, 
	MAX(Deaths) AS Max_Death,
    MIN(Deaths) AS Min_Death,
    AVG(Deaths) AS Avg_Death,
	MAX(Crude_Rate) AS Max_Crude_Rate,
    MIN(Crude_Rate) AS Min_Crude_Rate,
    AVG(Crude_Rate) AS Avg_Crude_Rate,
 	MAX(Percentage) AS Max_DeathPercentage,
    MIN(Percentage) AS Min_DeathPercentage,
    AVG(Percentage) AS Avg_DeathPercentage
FROM lcd_table2
WHERE Age_Range != 'All Ages'
GROUP BY Cause_Category
ORDER BY Max_Death DESC;
