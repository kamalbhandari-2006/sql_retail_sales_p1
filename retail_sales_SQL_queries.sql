--Cleaning
SELECT TOP 10 * 
FROM retails_sales
WHERE quantity < 0 OR price_per_unit < 0 OR cogs < 0 OR total_Sale <0

-- updates NULL age from orginal table by filling relative means in place of null values
WITH updated_Null_Age AS (
	SELECT 
	age,
	AVG(age)OVER (PARTITION BY gender,category) AS updated_age
	FROM [retails_sales]
	)

UPDATE updated_Null_Age
SET age = updated_age
WHERE age IS NULL

  
DELETE FROM retails_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL 
OR category IS NULL
OR quantiy	IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL

--Rename Column Quantiy to Quantity
EXEC sp_rename 'retails_sales.quantiy','quantity','COLUMN';

SELECT transactions_id,
COUNT(*) AS check_duplicacy
FROM retails_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1

--EDA

--Total Rows Count/Total Sales/How Many Sales We Have
SELECT COUNT(*) AS Total_Sales
FROM retails_sales

--Total Customers/How Many Unique Customers We Have
SELECT COUNT(DISTINCT customer_id) as Total_Customer FROM retails_sales

-- Diff Categories we have
SELECT DISTINCT category FROM retails_sales
-- check negative values 

--Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
-- Answers
--1 
SELECT * FROM retails_sales
WHERE sale_date = '2022-11-05'

--2
SELECT *
FROM retails_sales
WHERE category = 'Clothing'
AND
quantity >= 4
AND
YEAR(sale_date) = 2022 AND MONTH(sale_date) = 11
ORDER BY DAY(sale_date)

--3
SELECT category,SUM(total_sale) AS Sales_Per_Category
FROM retails_sales
GROUP BY category

--4
SELECT AVG(age) as Avg_Age
FROM retails_sales
WHERE category = 'Beauty'

--5
SELECT customer_id,total_sale,category,age
FROM retails_sales
WHERE total_sale > 1000

--6
SELECT 
COUNT(*) AS Total_Transactions,
gender,
category
FROM retails_sales
GROUP BY category,gender

--7
SELECT
*
FROM
(SELECT
YEAR(sale_date) AS Sales_Year,
DATENAME(MONTH,sale_date) AS Month_Name,
ROUND(AVG(total_sale),2)as AvgSales_Monthly,
MAX(ROUND(AVG(total_sale),2)) OVER(PARTITION BY YEAR(sale_date)) AS MaxSales
FROM retails_sales
GROUP BY DATENAME(MONTH,sale_date),YEAR(sale_date))t
WHERE MaxSales = AvgSales_Monthly

--OR--
--7
SELECT
*
FROM
(SELECT
YEAR(sale_date) AS Sales_Year,
DATENAME(MONTH,sale_date) AS Month_Name,
ROUND(AVG(total_sale),2)as AvgSales_Monthly,
RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) AS SalesRank
FROM retails_sales
GROUP BY DATENAME(MONTH,sale_date),YEAR(sale_date))t
WHERE SalesRank= 1

--8
SELECT 
	TOP 5
	RANK() OVER(ORDER BY SUM(total_sale)DESC) CustRank,
	Customer_id,
	SUM(total_sale) AS NetSales
FROM retails_sales
GROUP BY customer_id

--9
SELECT
COUNT(DISTINCT customer_id) AS unique_cust_count,
category
FROM retails_sales
GROUP BY category

--10
SELECT
	CASE
		WHEN DATEPART(HOUR,sale_time) <= 12 THEN 'Morning'
		WHEN DATEPART(HOUR,sale_time) <12 AND DATEPART(HOUR,sale_time) >= 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS hift
FROM retails_sales


SELECT TOP 10 * 
FROM retails_sales



