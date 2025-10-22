-- queries.sql — All analysis queries for Retail Sales Analysis (PostgreSQL dialect)

-- Count total records
SELECT COUNT(*) AS total_records FROM retail_sales;

-- Unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM retail_sales;

-- Unique categories
SELECT DISTINCT category FROM retail_sales;

-- Null check
SELECT *
FROM retail_sales
WHERE sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

-- Delete rows with nulls (use carefully!)
-- DELETE FROM retail_sales
-- WHERE sale_date IS NULL
--    OR sale_time IS NULL
--    OR customer_id IS NULL
--    OR gender IS NULL
--    OR age IS NULL
--    OR category IS NULL
--    OR quantity IS NULL
--    OR price_per_unit IS NULL
--    OR cogs IS NULL
--    OR total_sale IS NULL;

-- 1) Sales on specific date
SELECT *
FROM retail_sales
WHERE sale_date = DATE '2022-11-05';

-- 2) Clothing orders with quantity >= 4 in Nov-2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantity >= 4;

-- 3) Total sales by category
SELECT
  category,
  SUM(total_sale) AS net_sale,
  COUNT(*)        AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;

-- 4) Avg age for Beauty
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- 5) High value transactions
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- 6) Transactions by gender per category
SELECT
  category,
  gender,
  COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;

-- 7) Best month per year by avg sale
WITH monthly AS (
  SELECT
    EXTRACT(YEAR  FROM sale_date) AS yr,
    EXTRACT(MONTH FROM sale_date) AS mon,
    AVG(total_sale)               AS avg_sale
  FROM retail_sales
  GROUP BY 1, 2
),
ranked AS (
  SELECT
    yr, mon, avg_sale,
    RANK() OVER (PARTITION BY yr ORDER BY avg_sale DESC) AS rnk
  FROM monthly
)
SELECT yr, mon, avg_sale
FROM ranked
WHERE rnk = 1
ORDER BY yr;

-- 8) Top 5 customers by sales
SELECT
  customer_id,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- 9) Unique customers per category
SELECT
  category,
  COUNT(DISTINCT customer_id) AS cnt_unique_customers
FROM retail_sales
GROUP BY category
ORDER BY cnt_unique_customers DESC;

-- 10) Orders by shift
WITH hourly_sale AS (
  SELECT *,
         CASE
           WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
           WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
           ELSE 'Evening'
         END AS shift
  FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY total_orders DESC;
