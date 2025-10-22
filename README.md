# 🛍️ Retail Sales Analysis — SQL Project

A clean, beginner-friendly SQL project that demonstrates **database setup, data cleaning, EDA, and business-driven analysis** on retail sales data.


---

## 📂 Project Structure
```
sql_retail_sales/
├── README.md                # You are here
├── queries.sql              # All analysis queries in one place
└── (optional) data/         # Put CSV files here if you want to import
```

---

## 📊 Dataset
- **Transactions**: `transactions_id`, `sale_date`, `sale_time`, `customer_id`, `gender`, `age`, `category`, `quantity`, `price_per_unit`, `cogs`, `total_sale`
- **(Optional) Customers**: `customer_id`, `name`
- **(Optional) Markets**: `market_id`, `city`
- **Date table** (optional): useful for advanced time-series

> You can start with just the **Transactions** table and extend later.

---

## 🧱 Database Setup (PostgreSQL)
```sql
-- 1) Create database
CREATE DATABASE project_retail;

-- 2) Connect to project_retail, then create table
CREATE TABLE retail_sales (
  transactions_id   INT PRIMARY KEY,
  sale_date         DATE,
  sale_time         TIME,
  customer_id       INT,
  gender            VARCHAR(50),
  age               INT,
  category          VARCHAR(100),
  quantity          INT,
  price_per_unit    NUMERIC(10,2),
  cogs              NUMERIC(10,2),
  total_sale        NUMERIC(12,2)
);
```

> **MySQL tip:** replace `NUMERIC` with `DECIMAL`, and for date parts use `YEAR(sale_date)`, `MONTH(sale_date)` instead of `EXTRACT`.

---

## 🧹 Data Exploration & Cleaning
```sql
-- Record count
SELECT COUNT(*) AS total_records FROM retail_sales;

-- Unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers FROM retail_sales;

-- Unique categories
SELECT DISTINCT category FROM retail_sales;

-- Null value check
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

-- Remove rows with missing required data (only if appropriate)
DELETE FROM retail_sales
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
```

---

## 🔎 Business Questions & Queries
All queries are also available in **queries.sql**.

### 1) Sales on a specific date
```sql
SELECT *
FROM retail_sales
WHERE sale_date = DATE '2022-11-05';
```

### 2) Clothing orders with quantity ≥ 4 in Nov-2022
```sql
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantity >= 4;
-- MySQL: DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
```

### 3) Total sales by category
```sql
SELECT
  category,
  SUM(total_sale) AS net_sale,
  COUNT(*)        AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
```

### 4) Avg age of customers who bought from Beauty
```sql
SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

### 5) High value transactions (> 1000)
```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

### 6) Transactions by gender within each category
```sql
SELECT
  category,
  gender,
  COUNT(*) AS total_trans
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;
```

### 7) Best month per year by average sale
```sql
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
-- MySQL: use YEAR(sale_date), MONTH(sale_date) and window functions (MySQL 8+)
```

### 8) Top 5 customers by sales
```sql
SELECT
  customer_id,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

### 9) Unique customers per category
```sql
SELECT
  category,
  COUNT(DISTINCT customer_id) AS cnt_unique_customers
FROM retail_sales
GROUP BY category
ORDER BY cnt_unique_customers DESC;
```

### 10) Orders by shift (Morning <12, Afternoon 12–17, Evening >17)
```sql
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
-- MySQL: use HOUR(sale_time) instead of EXTRACT(HOUR FROM ...)
```

---

## 📈 Findings (example narrative)
- **Customer demographics:** Sales cover diverse ages across multiple categories (e.g., Clothing, Beauty).  
- **High-value orders:** Transactions over 1000 indicate premium purchases worth segmenting for campaigns.  
- **Seasonality:** Monthly averages reveal peak months to target for inventory and promos.  
- **Top customers:** Clear high-value cluster; candidates for loyalty offers and cross-sell.  

---

## 🧪 How to Run
1) Spin up a PostgreSQL instance (local Docker, pgAdmin, or managed cloud).  
2) Create the DB/table (see setup above).  
3) Load your data (COPY from CSV or INSERT).  
4) Run queries from `queries.sql`.  

---

## 📬 Contact
- Mail: gantisaianeesh@gmail.com  
- GitHub: https://github.com/Saianeesh2003

---

## 📝 License
MIT — feel free to use and adapt with attribution.
