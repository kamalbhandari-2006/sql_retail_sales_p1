# Retail Sales Analysis SQL Project

## Project Overview

**Project Title:** Retail Sales Analysis  
**Level:** Beginner  
**Database:** `sql_project_p2`  
**Tools:** Microsoft SQL Server, SQL Server Management Studio (SSMS), T-SQL

This project demonstrates SQL skills used in retail data analysis, including data quality checks, data cleaning, exploratory data analysis (EDA), and business-focused queries. The analysis uses a `retails_sales` table to explore sales performance, customer demographics, product categories, high-value transactions, monthly trends, and order volume by time of day.

## Objectives

- Set up a retail sales database in SQL Server.
- Inspect data for invalid values, missing fields, and duplicate transaction IDs.
- Impute missing customer ages using the average age within each gender and product category.
- Explore the dataset's size, customer count, and product categories.
- Answer business questions using filtering, aggregation, date functions, subqueries, and window functions.

## Project Structure

The project can be organized as follows:

```text
Retail-Sales-Analysis-SQL/
├── README.md
├── dataset/
│   └── retail_sales.csv
└── sql/
    └── retail_sales_analysis.sql
```

*The file and folder names above are a suggested layout. Adjust them to match the files in your repository.*

## Database Setup

Create and select the database:

```sql
CREATE DATABASE sql_project_p2;
GO

USE sql_project_p2;
GO
```

Import the retail sales dataset into a table named `retails_sales` using the SQL Server Import and Export Wizard, or use your existing table if it has already been created.

## Data Exploration and Cleaning

### 1. Check for negative values

```sql
SELECT TOP 10 *
FROM retails_sales
WHERE quantity < 0
   OR price_per_unit < 0
   OR cogs < 0
   OR total_sale < 0;
```

### 2. Impute missing ages

The query calculates the average age for each combination of gender and category, then uses that value to fill missing ages in the corresponding group.

```sql
WITH updated_Null_Age AS (
    SELECT
        age,
        AVG(age) OVER (PARTITION BY gender, category) AS updated_age
    FROM retails_sales
)
UPDATE updated_Null_Age
SET age = updated_age
WHERE age IS NULL;
```

**Note:** If an entire gender/category group has no non-NULL ages, its calculated average will also be `NULL`; those records will not be filled by this query.

### 3. Remove records missing required fields

```sql
DELETE FROM retails_sales
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantiy IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
```

### 4. Rename the misspelled column

```sql
EXEC sp_rename 'retails_sales.quantiy', 'quantity', 'COLUMN';
```

### 5. Check for duplicate transaction IDs

```sql
SELECT
    transactions_id,
    COUNT(*) AS check_duplicacy
FROM retails_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;
```

This query identifies duplicate IDs; it does not remove duplicates or enforce a primary key by itself.

## Exploratory Data Analysis (EDA)

### Total records

```sql
SELECT COUNT(*) AS Total_Sales
FROM retails_sales;
```

### Unique customers

```sql
SELECT COUNT(DISTINCT customer_id) AS Total_Customer
FROM retails_sales;
```

### Available product categories

```sql
SELECT DISTINCT category
FROM retails_sales;
```

## Business Questions and SQL Queries

The following T-SQL queries answer practical questions about the retail dataset.

### 1. Retrieve sales made on November 5, 2022

```sql
SELECT *
FROM retails_sales
WHERE sale_date = '2022-11-05';
```

### 2. Find Clothing transactions with a quantity of at least 4 in November 2022

```sql
SELECT *
FROM retails_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND YEAR(sale_date) = 2022
  AND MONTH(sale_date) = 11
ORDER BY DAY(sale_date);
```

### 3. Calculate total sales by category

```sql
SELECT
    category,
    SUM(total_sale) AS Sales_Per_Category
FROM retails_sales
GROUP BY category;
```

### 4. Find the average customer age for Beauty purchases

```sql
SELECT AVG(age) AS Avg_Age
FROM retails_sales
WHERE category = 'Beauty';
```

### 5. Find transactions with sales greater than 1,000

```sql
SELECT customer_id, total_sale, category, age
FROM retails_sales
WHERE total_sale > 1000;
```

### 6. Count transactions by gender and category

```sql
SELECT
    COUNT(*) AS Total_Transactions,
    gender,
    category
FROM retails_sales
GROUP BY category, gender;
```

### 7. Find the month with the highest average sale in each year

```sql
SELECT *
FROM (
    SELECT
        YEAR(sale_date) AS Sales_Year,
        DATENAME(MONTH, sale_date) AS Month_Name,
        ROUND(AVG(total_sale), 2) AS AvgSales_Monthly,
        RANK() OVER (
            PARTITION BY YEAR(sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS SalesRank
    FROM retails_sales
    GROUP BY DATENAME(MONTH, sale_date), YEAR(sale_date)
) AS t
WHERE SalesRank = 1;
```

This ranks months by **average sale value**, not by total monthly revenue. Ties for the highest average are included.

### 8. Find the top 5 customers by total sales

```sql
SELECT TOP 5
    RANK() OVER (ORDER BY SUM(total_sale) DESC) AS CustRank,
    customer_id,
    SUM(total_sale) AS NetSales
FROM retails_sales
GROUP BY customer_id
ORDER BY NetSales DESC;
```

### 9. Count unique customers in each category

```sql
SELECT
    COUNT(DISTINCT customer_id) AS unique_cust_count,
    category
FROM retails_sales
GROUP BY category;
```

### 10. Count orders by time-of-day shift

The shifts are defined as Morning (before 12:00), Afternoon (12:00 through 17:59), and Evening (18:00 onward).

```sql
SELECT
    Shift,
    COUNT(*) AS Total_Orders
FROM (
    SELECT *,
        CASE
            WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
            WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS Shift
    FROM retails_sales
) AS T
GROUP BY Shift
ORDER BY COUNT(*) DESC;
```

## Key Areas Explored

- **Data quality:** Auditing negative values, checking missing fields, and identifying duplicate transaction IDs.
- **Missing-value handling:** Filling missing ages using group-level averages where those averages are available.
- **Category performance:** Comparing total sales and transaction counts across product categories.
- **Customer analysis:** Counting distinct customers by category and ranking customers by total sales.
- **Time-based analysis:** Finding the month with the highest average sale per year and grouping orders into day shifts.
- **SQL techniques:** Using `WHERE`, `GROUP BY`, `HAVING`, aggregate functions, date functions, common table expressions, and window functions such as `RANK()`.

## Conclusion

This project applies SQL Server and T-SQL to clean, explore, and analyze retail sales data. It demonstrates how SQL can be used to check data quality, summarize category performance, understand customer purchasing patterns, and explore sales trends across dates and time-of-day shifts.

## How to Run the Project

1. Clone or download this repository.
2. Open SQL Server Management Studio and connect to your SQL Server instance.
3. Create the `sql_project_p2` database using the setup script.
4. Import the retail dataset into a table named `retails_sales`, ensuring the column names match the queries. If your original column is named `quantiy`, run the rename statement before queries that use `quantity`.
5. Run the cleaning and validation queries, then run the EDA and business-analysis queries.
6. Review the results in SSMS.

**Important:** The cleaning section includes `DELETE` and `UPDATE` statements that change data. Back up your table or test on a copy before running them.

## Author

**Kamal Bhandari**

This project is part of my data analytics portfolio and demonstrates foundational SQL skills relevant to data analyst roles.

If you have feedback or suggestions, feel free to connect through my GitHub profile.
