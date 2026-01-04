/* ============================================================
   PROJECT: E-Commerce Retail SQL Analytics
   DATASET: Online Retail
   TOOL: MySQL 8.x
   FILE LOCATION (required):
   C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\Online Retail.csv
   ============================================================ */


/* ===============================
   PHASE 1 — DATABASE SETUP
   =============================== */

CREATE DATABASE IF NOT EXISTS ecommerce_finance_sql;
USE ecommerce_finance_sql;


/* ===============================
   PHASE 2 — RAW TABLE (NO LOGIC)
   =============================== */

DROP TABLE IF EXISTS raw_online_retail;

CREATE TABLE raw_online_retail (
    InvoiceNo     VARCHAR(20),
    StockCode     VARCHAR(20),
    Description   VARCHAR(255),
    Quantity      INT,
    InvoiceDate   VARCHAR(25),
    UnitPrice     DECIMAL(10,2),
    CustomerID    VARCHAR(20),
    Country       VARCHAR(60)
);


/* ===============================
   PHASE 3 — LOAD CSV (SERVER SIDE)
   =============================== */

TRUNCATE TABLE raw_online_retail;

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Online Retail.csv'
INTO TABLE raw_online_retail
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(InvoiceNo, StockCode, Description, Quantity, InvoiceDate, UnitPrice, CustomerID, Country);


/* ===============================
   PHASE 4 — TECHNICAL CLEAN TABLE
   (Fix dates + null customer IDs)
   =============================== */

DROP TABLE IF EXISTS retail_clean;

CREATE TABLE retail_clean AS
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    NULLIF(CustomerID, '') AS CustomerID,
    Country,
    STR_TO_DATE(InvoiceDate, '%m/%d/%Y %H:%i') AS InvoiceDate
FROM raw_online_retail;


/* ===============================
   PHASE 5 — BUSINESS ANALYTICS TABLE
   =============================== */

DROP TABLE IF EXISTS retail_analytics;

CREATE TABLE retail_analytics AS
SELECT
    InvoiceNo,
    StockCode,
    Description,
    Quantity,
    UnitPrice,
    CustomerID,
    Country,
    InvoiceDate,

    CASE
        WHEN UnitPrice <= 0 OR Description IS NULL THEN 'INVALID'
        WHEN Quantity < 0 OR InvoiceNo LIKE 'C%' THEN 'RETURN'
        ELSE 'SALE'
    END AS transaction_type,

    CASE
        WHEN UnitPrice <= 0 OR Description IS NULL THEN 0
        ELSE UnitPrice * Quantity
    END AS row_revenue

FROM retail_clean;


/* ===============================
   PHASE 6 — SANITY CHECKS
   =============================== */

SELECT COUNT(*) AS total_rows FROM retail_analytics;

SELECT
    transaction_type,
    COUNT(*) AS ro
FROM retail_analytics
GROUP BY transaction_type;

SELECT
    transaction_type,
    SUM(row_revenue) AS revenue
FROM retail_analytics
GROUP BY transaction_type;


/* ===============================
   PHASE 7 — CORE METRICS
   =============================== */

-- Gross Revenue

SELECT
    SUM(row_revenue) AS gross_revenue
FROM retail_analytics
WHERE transaction_type = 'SALE';

-- Net Revenue

SELECT
    SUM(row_revenue) AS net_revenue
FROM retail_analytics
WHERE transaction_type IN ('SALE', 'RETURN');


/* ===============================
   PHASE 8 — REVENUE BY COUNTRY
   =============================== */

SELECT
    Country,
    SUM(row_revenue) AS gross_revenue
FROM retail_analytics
WHERE transaction_type = 'SALE'
GROUP BY Country
ORDER BY gross_revenue DESC;


/* ===============================
   PHASE 9 — MONTHLY TIME ANALYSIS
   =============================== */

-- Monthly Gross Revenue

SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    SUM(row_revenue) AS gross_revenue
FROM retail_analytics
WHERE transaction_type = 'SALE'
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY year, month;

-- Monthly Net Revenue

SELECT
    YEAR(InvoiceDate) AS year,
    MONTH(InvoiceDate) AS month,
    SUM(row_revenue) AS net_revenue
FROM retail_analytics
WHERE transaction_type IN ('SALE', 'RETURN')
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY year, month;


/* ===============================
   PHASE 10 — TOP CUSTOMERS
   =============================== */

SELECT
    CustomerID,
    SUM(row_revenue) AS net_revenue
FROM retail_analytics
WHERE transaction_type IN ('SALE', 'RETURN')
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY net_revenue DESC
LIMIT 10;

-- using window function 
SELECT
    CustomerID,
    SUM(row_revenue) AS net_revenue,
    RANK() OVER (ORDER BY SUM(row_revenue) DESC) AS revenue_rank
FROM retail_analytics
WHERE transaction_type IN ('SALE', 'RETURN')
  AND CustomerID IS NOT NULL
GROUP BY CustomerID;

-- percentage contribution, using cte + widows function

WITH customer_revenue AS (
    SELECT
        CustomerID,
        SUM(row_revenue) AS net_revenue
    FROM retail_analytics
    WHERE transaction_type IN ('SALE', 'RETURN')
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    net_revenue,
    net_revenue / SUM(net_revenue) OVER () * 100 AS revenue_percent
FROM customer_revenue
ORDER BY revenue_percent DESC;

/* ===============================
   PHASE 11 — ORDER / BASKET ANALYSIS (Basket size = how many items (or lines) are in one invoice)
   =============================== */

-- Basket size per order

SELECT
    InvoiceNo,
    COUNT(*) AS items_in_order
FROM retail_analytics
WHERE transaction_type = 'SALE'
GROUP BY InvoiceNo;

-- Basket size distribution

SELECT
    items_in_order,
    COUNT(*) AS number_of_orders
FROM (
    SELECT
        InvoiceNo,
        COUNT(*) AS items_in_order
    FROM retail_analytics
    WHERE transaction_type = 'SALE'
    GROUP BY InvoiceNo
) t
GROUP BY items_in_order
ORDER BY items_in_order;

-- Average basket size

SELECT
    AVG(items_in_order) AS avg_basket_size
FROM (
    SELECT
        InvoiceNo,
        COUNT(*) AS items_in_order
    FROM retail_analytics
    WHERE transaction_type = 'SALE'
    GROUP BY InvoiceNo
) t;

-- Basket size vs revenue

SELECT
    items_in_order,
    AVG(order_revenue) AS avg_order_revenue
FROM (
    SELECT
        InvoiceNo,
        COUNT(*) AS items_in_order,
        SUM(row_revenue) AS order_revenue
    FROM retail_analytics
    WHERE transaction_type = 'SALE'
    GROUP BY InvoiceNo
) t
GROUP BY items_in_order
ORDER BY items_in_order;

/* ============================================================
   PHASE 12 — Customer Frequency & Repeat Purchase Behavior
   Uses: retail_analytics (SALE/RETURN/INVALID already classified)
   Goal: Understand one-time vs repeat customers + revenue impact
   ============================================================ */

--  Orders per customer (SALE only, trackable customers)

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS number_of_orders
FROM retail_analytics
WHERE transaction_type = 'SALE'
  AND CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY number_of_orders DESC;


--  Segment customers by purchase frequency (counts)

SELECT
    CASE
        WHEN number_of_orders = 1 THEN 'One-time'
        WHEN number_of_orders BETWEEN 2 AND 5 THEN 'Occasional'
        ELSE 'Frequent'
    END AS customer_segment,
    COUNT(*) AS number_of_customers
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS number_of_orders
    FROM retail_analytics
    WHERE transaction_type = 'SALE'
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) t
GROUP BY customer_segment
ORDER BY number_of_customers DESC;


--  Segment revenue contribution (NET: SALE + RETURN)

SELECT
    customer_segment,
    SUM(net_revenue) AS segment_net_revenue
FROM (
    SELECT
        CustomerID,
        CASE
            WHEN COUNT(DISTINCT InvoiceNo) = 1 THEN 'One-time'
            WHEN COUNT(DISTINCT InvoiceNo) BETWEEN 2 AND 5 THEN 'Occasional'
            ELSE 'Frequent'
        END AS customer_segment,
        SUM(row_revenue) AS net_revenue
    FROM retail_analytics
    WHERE transaction_type IN ('SALE', 'RETURN')
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) t
GROUP BY customer_segment
ORDER BY segment_net_revenue DESC;


--  KPI: Average orders per customer (SALE only)

SELECT
    AVG(number_of_orders) AS avg_orders_per_customer
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS number_of_orders
    FROM retail_analytics
    WHERE transaction_type = 'SALE'
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) t;


-- (Optional) Quick KPI: Repeat rate (% customers with 2+ orders)

SELECT
    ROUND(
        100 * SUM(CASE WHEN number_of_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS repeat_customer_rate_pct
FROM (
    SELECT
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS number_of_orders
    FROM retail_analytics
    WHERE transaction_type = 'SALE'
      AND CustomerID IS NOT NULL
    GROUP BY CustomerID
) t;

