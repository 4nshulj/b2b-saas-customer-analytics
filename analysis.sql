/* ============================================================
SQL PORTFOLIO PROJECT: B2B SaaS Customer & Revenue Analysis
Author  : Anshul
Database: PostgreSQL
Dataset : Synthetic B2B SaaS platform — 1,000 customers,
10,000 orders, 50,000 order items, 15,000 activity logs
Purpose : End-to-end business analysis covering revenue,
customer behaviour, churn risk, product performance,
and funnel conversion — replicating real analyst work.
============================================================ */
/* ============================================================
SECTION 0 — SCHEMA SETUP & DATA GENERATION
============================================================ */
DROP TABLE IF EXISTS CUSTOMER_ACTIVITY1 CASCADE;

DROP TABLE IF EXISTS ORDER_ITEMS1 CASCADE;

DROP TABLE IF EXISTS ORDERS1 CASCADE;

DROP TABLE IF EXISTS PRODUCTS1 CASCADE;

DROP TABLE IF EXISTS CUSTOMERS1 CASCADE;

-- -----------------------------------------------------------
-- Dimension: Customers
-- Captures firmographic data — region, industry, revenue tier,
-- and the assigned account manager for each B2B client.
-- -----------------------------------------------------------
CREATE TABLE CUSTOMERS1 (
	CUSTOMER_ID INT PRIMARY KEY,
	CUSTOMER_NAME VARCHAR(100),
	SIGNUP_DATE DATE,
	REGION VARCHAR(50),
	INDUSTRY VARCHAR(50),
	ANNUAL_REVENUE DECIMAL(12, 2),
	ACCOUNT_MANAGER VARCHAR(100)
);

-- -----------------------------------------------------------
-- Dimension: Products
-- Product catalogue with category classification and list price.
-- -----------------------------------------------------------
CREATE TABLE PRODUCTS1 (
	PRODUCT_ID INT PRIMARY KEY,
	PRODUCT_NAME VARCHAR(100),
	CATEGORY VARCHAR(50),
	UNIT_PRICE DECIMAL(10, 2)
);

-- -----------------------------------------------------------
-- Fact: Orders
-- One row per transaction header; captures the sales channel
-- through which the customer placed the order.
-- -----------------------------------------------------------
CREATE TABLE ORDERS1 (
	ORDER_ID INT PRIMARY KEY,
	CUSTOMER_ID INT,
	ORDER_DATE DATE,
	SALES_CHANNEL VARCHAR(50),
	CONSTRAINT FK_ORDERS_CUSTOMER FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS1 (CUSTOMER_ID)
);

-- -----------------------------------------------------------
-- Fact: Order Items
-- Line-level detail — product, quantity, and discount applied.
-- Revenue = quantity × unit_price × (1 − discount_pct / 100)
-- -----------------------------------------------------------
CREATE TABLE ORDER_ITEMS1 (
	ORDER_ITEM_ID INT PRIMARY KEY,
	ORDER_ID INT,
	PRODUCT_ID INT,
	QUANTITY INT,
	DISCOUNT_PCT DECIMAL(5, 2),
	CONSTRAINT FK_ORDERITEMS_ORDER FOREIGN KEY (ORDER_ID) REFERENCES ORDERS1 (ORDER_ID),
	CONSTRAINT FK_ORDERITEMS_PRODUCT FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS1 (PRODUCT_ID)
);

-- -----------------------------------------------------------
-- Fact: Customer Activity
-- Monthly engagement signals — logins, support tickets, and
-- satisfaction scores. Used for churn-risk scoring.
-- -----------------------------------------------------------
CREATE TABLE CUSTOMER_ACTIVITY1 (
	ACTIVITY_ID INT PRIMARY KEY,
	CUSTOMER_ID INT,
	ACTIVITY_DATE DATE,
	LOGIN_COUNT INT,
	SUPPORT_TICKETS INT,
	SATISFACTION_SCORE DECIMAL(3, 1),
	CONSTRAINT FK_ACTIVITY_CUSTOMER FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS1 (CUSTOMER_ID)
);

-- -----------------------------------------------------------
-- Seed Data: Products (20 SKUs across 6 categories)
-- -----------------------------------------------------------
INSERT INTO
	PRODUCTS1
VALUES
	(1, 'CRM Enterprise', 'Software', 1200),
	(2, 'CRM Starter', 'Software', 300),
	(3, 'Cloud Storage 1TB', 'Cloud', 120),
	(4, 'Cloud Storage 10TB', 'Cloud', 950),
	(5, 'Data Analytics Suite', 'Analytics', 1800),
	(6, 'BI Dashboard Pro', 'Analytics', 750),
	(7, 'Marketing Automation', 'Marketing', 650),
	(8, 'Email Campaign Pro', 'Marketing', 220),
	(9, 'Customer Support AI', 'Support', 1400),
	(10, 'Chatbot Enterprise', 'Support', 900),
	(11, 'Fraud Detection Engine', 'Finance', 2500),
	(12, 'Risk Monitoring Suite', 'Finance', 1700),
	(13, 'HR Payroll Pro', 'HR', 850),
	(14, 'Talent Analytics', 'HR', 650),
	(15, 'Inventory Optimizer', 'Operations', 1400),
	(16, 'Supply Chain Tracker', 'Operations', 1600),
	(17, 'Customer Insights AI', 'Analytics', 2200),
	(18, 'Advanced Reporting', 'Analytics', 500),
	(19, 'Campaign Intelligence', 'Marketing', 950),
	(20, 'Service Desk Premium', 'Support', 1200);

-- -----------------------------------------------------------
-- Seed Data: 1,000 synthetic customers
-- -----------------------------------------------------------
INSERT INTO
	CUSTOMERS1
SELECT
	GS,
	'Customer_' || GS,
	DATE '2020-01-01' + (RANDOM() * 1500)::INT,
	(
		ARRAY[
			'North America',
			'Europe',
			'Asia Pacific',
			'Middle East',
			'South America'
		]
	) [FLOOR(RANDOM() * 5 + 1)],
	(
		ARRAY[
			'Retail',
			'Technology',
			'Finance',
			'Healthcare',
			'Manufacturing',
			'Telecom',
			'Education'
		]
	) [FLOOR(RANDOM() * 7 + 1)],
	ROUND((100000 + RANDOM() * 10000000)::NUMERIC, 2),
	'Manager_' || FLOOR(RANDOM() * 25 + 1)
FROM
	GENERATE_SERIES(1, 1000) GS;

-- -----------------------------------------------------------
-- Seed Data: 10,000 orders (2022 – 2024)
-- -----------------------------------------------------------
INSERT INTO
	ORDERS1
SELECT
	GS,
	FLOOR(RANDOM() * 1000 + 1)::INT,
	DATE '2022-01-01' + (RANDOM() * 900)::INT,
	(
		ARRAY[
			'Online',
			'Direct Sales',
			'Partner',
			'Marketplace'
		]
	) [FLOOR(RANDOM() * 4 + 1)]
FROM
	GENERATE_SERIES(1, 10000) GS;

-- -----------------------------------------------------------
-- Seed Data: 50,000 order line items
-- -----------------------------------------------------------
INSERT INTO
	ORDER_ITEMS1
SELECT
	GS,
	FLOOR(RANDOM() * 10000 + 1)::INT,
	FLOOR(RANDOM() * 20 + 1)::INT,
	FLOOR(RANDOM() * 25 + 1)::INT,
	ROUND((RANDOM() * 30)::NUMERIC, 2)
FROM
	GENERATE_SERIES(1, 50000) GS;

-- -----------------------------------------------------------
-- Seed Data: 15,000 customer activity records (2023 – 2024)
-- NULLs are intentionally injected (~10–20 %) to simulate
-- real-world data quality issues.
-- -----------------------------------------------------------
INSERT INTO
	CUSTOMER_ACTIVITY1
SELECT
	GS,
	FLOOR(RANDOM() * 1000 + 1)::INT,
	DATE '2023-01-01' + (RANDOM() * 700)::INT,
	CASE
		WHEN RANDOM() < 0.10 THEN NULL
		ELSE FLOOR(RANDOM() * 50)::INT
	END,
	CASE
		WHEN RANDOM() < 0.20 THEN NULL
		ELSE FLOOR(RANDOM() * 15)::INT
	END,
	CASE
		WHEN RANDOM() < 0.15 THEN NULL
		ELSE ROUND((1 + RANDOM() * 4)::NUMERIC, 1)
	END
FROM
	GENERATE_SERIES(1, 15000) GS;

-- -----------------------------------------------------------
-- Sanity Check — verify row counts before analysis
-- -----------------------------------------------------------
SELECT
	'customers1' AS TABLE_NAME,
	COUNT(*) AS ROW_COUNT
FROM
	CUSTOMERS1
UNION ALL
SELECT
	'products1',
	COUNT(*)
FROM
	PRODUCTS1
UNION ALL
SELECT
	'orders1',
	COUNT(*)
FROM
	ORDERS1
UNION ALL
SELECT
	'order_items1',
	COUNT(*)
FROM
	ORDER_ITEMS1
UNION ALL
SELECT
	'customer_activity1',
	COUNT(*)
FROM
	CUSTOMER_ACTIVITY1;

-- 1.  Preview the first 10 customers
--      Quick sanity check — confirm columns, data types, and
--      that no obvious data corruption exists.
SELECT
	*
FROM
	CUSTOMERS1
LIMIT
	10;

-- 2.  Distribution of customers by region
--      Understand the geographic spread of the customer base.
--      Useful for deciding where to prioritise sales resources.
SELECT
	REGION,
	COUNT(*) AS TOTAL_CUSTOMERS
FROM
	CUSTOMERS1
GROUP BY
	REGION
ORDER BY
	TOTAL_CUSTOMERS DESC;

-- 3.  Distribution of customers by industry
--      Identifies which verticals drive the most accounts —
--      critical for persona-based marketing.
SELECT
	INDUSTRY,
	COUNT(*) AS TOTAL_CUSTOMERS
FROM
	CUSTOMERS1
GROUP BY
	INDUSTRY
ORDER BY
	TOTAL_CUSTOMERS DESC;

-- 4. Revenue by Sales Channel
--    Purpose: Calculate total revenue generated through each sales channel
--    after applying product-level discounts.
--
--    Revenue Formula:
--    Revenue = Quantity × Unit Price × (1 − Discount Rate)
--
--    Business Objective:
--    To identify and compare revenue contribution across sales channels,
--    and evaluate order volume distribution to assess overall channel
--    performance and effectiveness.
SELECT
	O.SALES_CHANNEL,
	COUNT(DISTINCT O.ORDER_ID) AS TOTAL_ORDERS,
	ROUND(
		SUM(
			P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
		),
		2
	) AS TOTAL_REVENUE
FROM
	ORDERS1 O
	JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	O.SALES_CHANNEL
	-- 5. Average Order Value (AOV) by Sales Channel
	--    Purpose: Calculate the average revenue generated per order
	--    across each sales channel.
	--
	--    Business Insight:
	--    This metric helps distinguish between high-value channels
	--    (fewer but larger orders) and high-volume, low-value channels
	--    (many but smaller orders), enabling better channel strategy
	--    and marketing optimization.
SELECT
	O.SALES_CHANNEL,
	COUNT(DISTINCT O.ORDER_ID) AS TOTAL_ORDERS,
	ROUND(
		SUM(
			P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
		) / COUNT(DISTINCT O.ORDER_ID),
		2
	) AS AVERAGE_ORDER_VALUE
FROM
	ORDERS1 O
	JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	O.SALES_CHANNEL
	-- 6. Revenue by Product Category
	--    Purpose: Calculate total revenue and order volume across
	--    each product category.
	--
	--    Business Insight:
	--    This analysis highlights top-performing product categories
	--    based on revenue contribution and order frequency, supporting
	--    data-driven decisions for inventory planning and portfolio
	--    optimization.
SELECT
	P.CATEGORY,
	ROUND(
		SUM(
			P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
		),
		2
	) AS TOTAL_REVENUE,
	COUNT(DISTINCT O.ORDER_ID) AS TOTAL_ORDERS
FROM
	ORDERS1 O
	JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	P.CATEGORY
	-- 7. Customers with No Orders
	--    Purpose: Identify customers who have registered but have not
	--    placed any orders.
	--
	--    Business Insight:
	--    These customers represent non-converting users and provide
	--    an opportunity for targeted onboarding, engagement, and
	--    activation strategies to improve conversion rates.
SELECT
	C.CUSTOMER_ID,
	C.CUSTOMER_NAME,
	C.REGION,
	C.INDUSTRY,
	C.SIGNUP_DATE
FROM
	CUSTOMERS1 C
	LEFT JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
WHERE
	O.ORDER_ID IS NULL
GROUP BY
	C.CUSTOMER_ID
	-- 8. RFM Analysis (Recency, Frequency, Monetary)
	--    Purpose: Segment customers based on purchasing behavior using RFM metrics.
	--
	--    RFM Components:
	--      - Recency: Days since last purchase (calculated using dataset max order_date)
	--      - Frequency: Total number of orders placed by each customer
	--      - Monetary: Total revenue generated by each customer
	--
	--    Business Insight:
	--    This segmentation helps identify:
	--      - High-value loyal customers (Champions)
	--      - At-risk customers with declining engagement
	--      - Potential growth segments for targeted marketing campaigns
	--
	--    Note:
	--    Recency is calculated using the latest order_date in the dataset
	--    instead of CURRENT_DATE to ensure consistent historical analysis.
WITH
	REFERENCE_DATE AS (
		SELECT
			MAX(ORDER_DATE) AS REF_DATE
		FROM
			ORDERS1
	)
SELECT
	C.CUSTOMER_ID,
	C.CUSTOMER_NAME,
	(R.REF_DATE - MAX(O.ORDER_DATE)) AS RECENECY_DAYS,
	COUNT(DISTINCT O.ORDER_ID) AS FREQUENCY,
	SUM(C.ANNUAL_REVENUE) AS MONETARY
FROM
	CUSTOMERS1 C
	LEFT JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
	CROSS JOIN REFERENCE_DATE R
GROUP BY
	C.CUSTOMER_ID,
	C.CUSTOMER_NAME,
	R.REF_DATE
	-- 9. Above Average Revenue Customers
	--    Purpose: Identify customers whose total revenue contribution
	--    exceeds the overall average customer revenue.
	--
	--    Business Insight:
	--    These customers represent high-value accounts and should be
	--    prioritized for retention strategies, upselling opportunities,
	--    and enhanced account management focus.
WITH
	CUSTOMER_REVENUE AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			C.REGION,
			C.INDUSTRY,
			ROUND(
				SUM(
					OI.QUANTITY * P.UNIT_PRICE * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			C.REGION,
			C.INDUSTRY
	)
SELECT
	*
FROM
	CUSTOMER_REVENUE
WHERE
	TOTAL_REVENUE > (
		SELECT
			AVG(TOTAL_REVENUE)
		FROM
			CUSTOMER_REVENUE
	)
ORDER BY
	TOTAL_REVENUE DESC;

-- 10. Top Customers by Revenue
--     Purpose: Identify and rank customers based on total revenue contribution.
--
--     Business Insight:
--     This analysis highlights the most valuable customers, enabling
--     targeted retention strategies, personalized engagement, and
--     strategic account management to maximize long-term value.
WITH
	CTE AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	),
	RANKS AS (
		SELECT
			*,
			DENSE_RANK() OVER (
				ORDER BY
					TOTAL_REVENUE DESC
			) AS RNK
		FROM
			CTE
	)
SELECT
	RNK,
	CUSTOMER_ID,
	CUSTOMER_NAME,
	TOTAL_REVENUE
FROM
	RANKS
WHERE
	RNK <= 10
	-- 11. Customer Revenue Share (%)
	--     Purpose: Calculate each customer's contribution as a percentage
	--     of total revenue.
	--
	--     Business Insight:
	--     This helps identify revenue concentration, key accounts driving
	--     business performance, and potential dependency risks on top
	--     customers.
WITH
	CTE AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS CUSTOMER_REVENUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	),
	REVENUE_SHARE AS (
		SELECT
			*,
			SUM(CUSTOMER_REVENUE) OVER () AS TOTAL_REVENUE
		FROM
			CTE
	)
SELECT
	*,
	ROUND(CUSTOMER_REVENUE * 100.0 / TOTAL_REVENUE, 2) AS REVENUE_SHARE_PCT
FROM
	REVENUE_SHARE
	-- 12. NTILE(5) — Customer Segmentation Logic
	-- Purpose: Segment customers into five equal-sized groups based on
	-- total revenue, ranked from highest to lowest.
	--
	-- How it works:
	--   - Customers are ordered by total revenue (descending)
	--   - Data is divided into 5 approximately equal buckets
	--   - Each bucket is assigned a value from 1 to 5:
	--       1 → Top 20% (highest-value customers)
	--       5 → Bottom 20% (lowest-value customers)
	--
	-- Business Use:
	-- This segmentation supports Customer Lifetime Value (CLV) analysis,
	-- enabling identification of VIP customers, growth opportunities,
	-- and low-value segments for targeted marketing and retention strategies.
WITH
	CUSTOMER_METRICS AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			COUNT(DISTINCT O.ORDER_ID) AS TOTAL_ORDERS,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				) / COUNT(DISTINCT O.ORDER_ID),
				2
			) AS AVG_ORDER_VALUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	),
	RANKED_CUSTOMERS AS (
		SELECT
			*,
			NTILE(5) OVER (
				ORDER BY
					TOTAL_REVENUE DESC
			) AS TILE
		FROM
			CUSTOMER_METRICS
	)
SELECT
	CUSTOMER_ID,
	CUSTOMER_NAME,
	TOTAL_REVENUE,
	TOTAL_ORDERS,
	AVG_ORDER_VALUE,
	CASE
		WHEN TILE = 1 THEN 'High Value'
		WHEN TILE BETWEEN 2 AND 4  THEN 'Medium Value'
		WHEN TILE = 5 THEN 'Low Value'
	END AS VALUE_SEGMENT
FROM
	RANKED_CUSTOMERS
ORDER BY
	TOTAL_REVENUE DESC;

-- 13. Monthly Revenue Trend
--     Purpose: Track total revenue on a monthly basis to analyze
--     business performance over time.
--
--     Business Insight:
--     This helps identify seasonality, growth trends, and revenue
--     fluctuations, supporting forecasting and strategic decision-making.
SELECT
	DATE_TRUNC('Month', O.ORDER_DATE)::DATE AS MONTH,
	ROUND(
		SUM(
			P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
		),
		2
	) AS TOTAL_REVENUE
FROM
	ORDERS1 O
	JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS1 P ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY
	DATE_TRUNC('Month', O.ORDER_DATE)
	-- 14. Month-over-Month (MoM) Revenue Growth
	--     Purpose: Measure monthly revenue growth by comparing each
	--     month with the previous month.
	--
	--     Business Insight:
	--     This analysis helps track business momentum, highlighting
	--     periods of acceleration, slowdown, or seasonal fluctuations
	--     in revenue performance.
WITH
	CTE AS (
		SELECT
			DATE_TRUNC('Month', O.ORDER_DATE)::DATE AS MONTH,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			ORDERS1 O
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON P.PRODUCT_ID = OI.PRODUCT_ID
		GROUP BY
			DATE_TRUNC('Month', O.ORDER_DATE)
	),
	PREV_REV AS (
		SELECT
			*,
			LAG(TOTAL_REVENUE) OVER (
				ORDER BY
					MONTH
			) AS PREV_MONTH_REVENUE
		FROM
			CTE
	)
SELECT
	*,
	ROUND(
		(TOTAL_REVENUE - PREV_MONTH_REVENUE) * 100.0 / PREV_MONTH_REVENUE,
		2
	) AS MOM_GROWTH_PCT
FROM
	PREV_REV
	-- 15. Top Customers by Revenue Share (%)
	--     Purpose: Identify customers contributing the highest share
	--     of total company revenue.
	--
	--     Business Insight:
	--     This helps evaluate revenue concentration risk and highlights
	--     key accounts that are critical for business stability and
	--     long-term growth.
WITH
	CTE AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS CUSTOMER_REVENUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	),
	REVENUE_SHARE AS (
		SELECT
			*,
			SUM(CUSTOMER_REVENUE) OVER () AS TOTAL_REVENUE
		FROM
			CTE
	),
	RANKS AS (
		SELECT
			*,
			ROUND(CUSTOMER_REVENUE * 100.0 / TOTAL_REVENUE, 2) AS REVENUE_SHARE_PCT,
			DENSE_RANK() OVER (
				ORDER BY
					ROUND(CUSTOMER_REVENUE * 100.0 / TOTAL_REVENUE, 2) DESC
			) AS RNK
		FROM
			REVENUE_SHARE
	)
SELECT
	RNK,
	CUSTOMER_ID,
	CUSTOMER_NAME,
	TOTAL_REVENUE,
	REVENUE_SHARE_PCT
FROM
	RANKS
WHERE
	RNK <= 5
	-- 16. Top Products by Revenue
	--     Purpose: Identify products that generate the highest revenue.
	--
	--     Business Insight:
	--     This analysis helps prioritize best-selling products for
	--     marketing strategies, inventory planning, and overall
	--     business focus to maximize profitability.
WITH
	CTE AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.CATEGORY,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			ORDERS1 O
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.CATEGORY
	),
	RANKS AS (
		SELECT
			*,
			DENSE_RANK() OVER (
				ORDER BY
					TOTAL_REVENUE DESC
			) AS RNK
		FROM
			CTE
	)
SELECT
	RNK,
	PRODUCT_ID,
	PRODUCT_NAME,
	CATEGORY,
	TOTAL_REVENUE
FROM
	RANKS
WHERE
	RNK <= 10
	-- 17. Monthly Active Customers
	--     Purpose: Count unique customers who placed at least one order
	--     in each month.
	--
	--     Business Insight:
	--     This metric helps track customer engagement trends over time
	--     and provides insight into user retention and platform activity.
SELECT
	DATE_TRUNC('month', ORDER_DATE)::DATE AS MONTH,
	COUNT(DISTINCT CUSTOMER_ID) AS ACTIVE_CUSTOMERS
FROM
	ORDERS1
GROUP BY
	DATE_TRUNC('month', ORDER_DATE)
ORDER BY
	MONTH;

-- 18. Repeat Customers per Month
--     Purpose: Identify and count customers who placed more than
--     one order within the same month.
--
--     Business Insight:
--     This metric helps evaluate customer loyalty and engagement
--     by highlighting repeat purchasing behavior over time.
WITH
	CUSTOMER_MONTHLY_ORDERS AS (
		SELECT
			DATE_TRUNC('month', ORDER_DATE)::DATE AS MONTH,
			CUSTOMER_ID,
			COUNT(ORDER_ID) AS ORDER_COUNT
		FROM
			ORDERS1
		GROUP BY
			DATE_TRUNC('month', ORDER_DATE),
			CUSTOMER_ID
	)
SELECT
	MONTH,
	COUNT(CUSTOMER_ID) AS REPEAT_CUSTOMERS
FROM
	CUSTOMER_MONTHLY_ORDERS
WHERE
	ORDER_COUNT > 1
GROUP BY
	MONTH
ORDER BY
	MONTH;

-- 19. Month 1 to Month 2 Customer Retention (COUNT)
--     Purpose: Identify customers who made a purchase in a given month
--     and returned to make another purchase in the following month.
--
--     Business Insight:
--     This metric measures early customer stickiness and engagement behavior,
--     serving as a key indicator of product adoption and potential churn risk.
--
--     Metric Type:
--     Absolute retention (raw customer count, not percentage)
WITH
	CTE AS (
		SELECT
			CUSTOMER_ID,
			DATE_TRUNC('Month', ORDER_DATE) AS MONTH
		FROM
			ORDERS1
		GROUP BY
			CUSTOMER_ID,
			DATE_TRUNC('Month', ORDER_DATE)
	),
	RETAINED AS (
		SELECT
			A.MONTH AS CURRENT_MONTH,
			COUNT(DISTINCT A.CUSTOMER_ID) AS RETAINED_CUSTOMERS
		FROM
			CTE A
			JOIN CTE B ON A.CUSTOMER_ID = B.CUSTOMER_ID
			AND B.MONTH = A.MONTH + INTERVAL '1 month'
		GROUP BY
			A.MONTH
	)
SELECT
	*
FROM
	RETAINED
ORDER BY
	CURRENT_MONTH
	-- 20. Month 1 to Month 2 Retention Rate (%)
	--     Purpose: Measure the percentage of customers who return
	--     and make a purchase in the subsequent month.
	--
	--     Business Insight:
	--     This is a key retention KPI that indicates product stickiness,
	--     customer satisfaction, and early-stage churn behavior.
WITH
	MONTHLY_CUSTOMERS AS (
		SELECT
			CUSTOMER_ID,
			DATE_TRUNC('month', ORDER_DATE)::DATE AS MONTH
		FROM
			ORDERS1
		GROUP BY
			CUSTOMER_ID,
			DATE_TRUNC('month', ORDER_DATE)
	),
	RETAINED AS (
		SELECT
			A.MONTH AS CURRENT_MONTH,
			COUNT(DISTINCT A.CUSTOMER_ID) AS RETAINED_CUSTOMERS
		FROM
			MONTHLY_CUSTOMERS A
			JOIN MONTHLY_CUSTOMERS B ON A.CUSTOMER_ID = B.CUSTOMER_ID
			AND B.MONTH = A.MONTH + INTERVAL '1 month'
		GROUP BY
			A.MONTH
	),
	TOTAL AS (
		SELECT
			MONTH AS CURRENT_MONTH,
			COUNT(DISTINCT CUSTOMER_ID) AS TOTAL_CUSTOMERS
		FROM
			MONTHLY_CUSTOMERS
		GROUP BY
			MONTH
	)
SELECT
	T.CURRENT_MONTH,
	T.TOTAL_CUSTOMERS,
	COALESCE(R.RETAINED_CUSTOMERS, 0) AS RETAINED_CUSTOMERS,
	ROUND(
		COALESCE(R.RETAINED_CUSTOMERS, 0) * 100.0 / T.TOTAL_CUSTOMERS,
		2
	) AS RETENTION_RATE_PCT
FROM
	TOTAL T
	LEFT JOIN RETAINED R ON T.CURRENT_MONTH = R.CURRENT_MONTH
ORDER BY
	T.CURRENT_MONTH;

-- 21. Inactive Customers (Dataset-based logic)
--     Purpose: Identify customers who have not placed any orders in the
--     last 6 months of the dataset's available time range.
--
--     Business Insight:
--     This analysis detects customer inactivity and potential churn using
--     the maximum order date present in the dataset as a reference point
--     instead of CURRENT_DATE. It helps identify customers who are no longer
--     engaged, enabling targeted retention strategies, re-engagement campaigns,
--     and churn reduction efforts in a static dataset environment.
WITH
	MAX_DATE AS (
		SELECT
			MAX(ORDER_DATE) AS MAX_ORDER_DATE
		FROM
			ORDERS1
	),
	CUSTOMER_LAST_ORDER AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			MAX(O.ORDER_DATE) AS LAST_ORDER_DATE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	)
SELECT
	CLO.CUSTOMER_ID,
	CLO.CUSTOMER_NAME,
	CLO.LAST_ORDER_DATE
FROM
	CUSTOMER_LAST_ORDER CLO
	CROSS JOIN MAX_DATE M
WHERE
	CLO.LAST_ORDER_DATE < (M.MAX_ORDER_DATE - INTERVAL '6 months')
ORDER BY
	CLO.LAST_ORDER_DATE;

-- 22. Top-Selling Products by Quantity
--     Purpose: Identify the products with the highest total units sold
--     across all customer orders.
--
--     Business Insight:
--     This analysis highlights the most popular products based on sales
--     volume rather than revenue. It helps support inventory planning,
--     demand forecasting, procurement decisions, and marketing strategies
--     by identifying products with consistently high customer demand.
WITH
	CTE AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.CATEGORY,
			SUM(OI.QUANTITY) AS TOTAL_QUANTITY
		FROM
			PRODUCTS1 P
			JOIN ORDER_ITEMS1 OI ON P.PRODUCT_ID = OI.PRODUCT_ID
		GROUP BY
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.CATEGORY
	),
	RANKS AS (
		SELECT
			*,
			DENSE_RANK() OVER (
				ORDER BY
					TOTAL_QUANTITY DESC
			) AS RNK
		FROM
			CTE
	)
SELECT
	RNK,
	PRODUCT_ID,
	PRODUCT_NAME,
	CATEGORY,
	TOTAL_QUANTITY
FROM
	RANKS
WHERE
	RNK <= 10
	-- 23. Identify product pairs purchased together within the same order.
	-- Logic:
	-- A self-join is performed on order_items1 using order_id to find products
	-- purchased in the same transaction. The condition a.product_id < b.product_id
	-- ensures that:
	--   1. Each product pair is counted only once (eliminates duplicates like A-B and B-A)
	--   2. Self-pairs (A-A) are excluded
	--
	-- Business Insight:
	-- This forms the foundation of market basket analysis and is used for
	-- product bundling, cross-sell strategies, and recommendation systems.
SELECT
	P1.PRODUCT_NAME AS PRODUCT_1,
	P2.PRODUCT_NAME AS PRODUCT_2,
	COUNT(*) AS BOUGHT_TOGETHER
FROM
	ORDER_ITEMS1 A
	JOIN ORDER_ITEMS1 B ON A.ORDER_ID = B.ORDER_ID
	AND A.PRODUCT_ID < B.PRODUCT_ID
	JOIN PRODUCTS1 P1 ON A.PRODUCT_ID = P1.PRODUCT_ID
	JOIN PRODUCTS1 P2 ON B.PRODUCT_ID = P2.PRODUCT_ID
GROUP BY
	P1.PRODUCT_NAME,
	P2.PRODUCT_NAME
ORDER BY
	BOUGHT_TOGETHER DESC
	-- 24. Pareto Analysis (80/20 Rule)
	--     Purpose: Identify how revenue is distributed across customers and
	--     determine whether a small percentage of customers contribute to
	--     the majority of total revenue.
	--
	--     Business Insight:
	--     This analysis applies the Pareto principle to customer revenue data.
	--     Customers are ranked by revenue contribution, and a cumulative
	--     percentage is calculated to identify the point at which ~80% of
	--     total revenue is achieved. This helps in recognizing high-value
	--     customers, understanding revenue concentration risk, and guiding
	--     retention and upselling strategies.
WITH
	CTE AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			ROUND(
				SUM(
					OI.QUANTITY * P.UNIT_PRICE * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS REVENUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	),
	CUM_REV AS (
		SELECT
			*,
			SUM(REVENUE) OVER (
				ORDER BY
					REVENUE DESC
			) AS CUMULATIVE_REVENUE,
			SUM(REVENUE) OVER () AS TOTAL_REVENUE
		FROM
			CTE
	)
SELECT
	*,
	ROUND(CUMULATIVE_REVENUE * 100.0 / TOTAL_REVENUE, 2) AS CUMULATIVE_PCT
FROM
	CUM_REV
ORDER BY
	REVENUE DESC
	-- 25. Customer Purchase Frequency Segmentation
	--     Purpose: Segment customers based on how frequently they place orders
	--     in order to understand engagement and buying behavior patterns.
	--
	--     Business Insight:
	--     This analysis classifies customers into High, Medium, and Low frequency
	--     segments based on total order count. It helps identify loyal customers
	--     (high engagement), occasional buyers, and low-engagement customers who
	--     may be at risk of churn. This segmentation supports targeted marketing,
	--     retention strategies, and customer lifecycle management.
WITH
	CUSTOMER_ORDERS AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			COUNT(O.ORDER_ID) AS TOTAL_ORDERS
		FROM
			CUSTOMERS1 C
			LEFT JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME
	)
SELECT
	CUSTOMER_ID,
	CUSTOMER_NAME,
	TOTAL_ORDERS,
	CASE
		WHEN TOTAL_ORDERS >= 5 THEN 'High Frequency'
		WHEN TOTAL_ORDERS BETWEEN 2 AND 4  THEN 'Medium Frequency'
		ELSE 'Low Frequency'
	END AS FREQUENCY_SEGMENT
FROM
	CUSTOMER_ORDERS
ORDER BY
	TOTAL_ORDERS DESC;

-- 26. Rolling 3-Month Revenue Trend
--     Purpose: Analyze revenue trends using a rolling average to smooth
--     short-term fluctuations and better understand overall business growth
--     patterns over time.
--
--     Business Insight:
--     This analysis calculates monthly revenue and applies a 3-month rolling
--     average using window functions. It helps remove noise caused by seasonality
--     or irregular spikes, making it easier to identify true revenue trends,
--     growth momentum, and potential slowdowns. This is commonly used for
--     forecasting and strategic planning.
WITH
	MONTHLY_REVENUE AS (
		SELECT
			DATE_TRUNC('month', O.ORDER_DATE)::DATE AS MONTH,
			SUM(
				P.PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PERCENT, 0) / 100.0)
			) AS REVENUE
		FROM
			ORDERS1 O
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			DATE_TRUNC('month', O.ORDER_DATE)
	)
SELECT
	MONTH,
	REVENUE,
	ROUND(
		AVG(REVENUE) OVER (
			ORDER BY
				MONTH ROWS BETWEEN 2 PRECEDING
				AND CURRENT ROW
		),
		2
	) AS ROLLING_3_MONTH_AVG
FROM
	MONTHLY_REVENUE
ORDER BY
	MONTH;

-- 27. Customer Churn  Analysis
--     Purpose: Identify customers who have not made any purchases recently
--     based on the latest available order date in the dataset.
--
--     Business Insight:
--     This analysis calculates each customer's last purchase date and compares
--     it with the maximum order date in the dataset to compute inactivity duration.
--     Customers are then segmented into Active, At Risk, and Churned categories
--     based on days of inactivity. This helps in understanding customer retention,
--     identifying churn risk, and supporting targeted win-back campaigns and
--     retention strategies.
WITH
	LAST_DATE AS (
		SELECT
			MAX(ORDER_DATE) AS LAST_DATE
		FROM
			ORDERS1
	),
	CHURN_DAY AS (
		SELECT
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			MAX(O.ORDER_DATE) AS LAST_PURCHASE_DATE,
			L.LAST_DATE - MAX(O.ORDER_DATE) AS DAYS_INACTIVE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			CROSS JOIN LAST_DATE L
		GROUP BY
			C.CUSTOMER_ID,
			C.CUSTOMER_NAME,
			L.LAST_DATE
	)
SELECT
	*,
	CASE
		WHEN DAYS_INACTIVE >= 100 THEN 'Churned'
		WHEN DAYS_INACTIVE >= 90 THEN 'At Risk'
		ELSE 'Active'
	END AS STATUS
FROM
	CHURN_DAY
	-- 28. Product Revenue Contribution (%)
	--     Purpose: Calculate each product’s contribution to total company revenue
	--     to identify high-performing and low-performing products.
	--
	--     Business Insight:
	--     This analysis computes total revenue generated by each product and
	--     expresses it as a percentage of overall revenue. It helps identify
	--     key revenue-driving products (hero products), detect underperforming
	--     items, and understand revenue concentration across the product portfolio.
	--     This insight supports pricing strategy, product prioritization, and
	--     marketing focus decisions.
WITH
	PRODUCT_REVENUE AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS REVENUE
		FROM
			PRODUCTS1 P
			JOIN ORDER_ITEMS1 OI ON P.PRODUCT_ID = OI.PRODUCT_ID
		GROUP BY
			P.PRODUCT_ID,
			P.PRODUCT_NAME
	),
	TOTAL_REVENUE AS (
		SELECT
			SUM(REVENUE) AS TOTAL_REV
		FROM
			PRODUCT_REVENUE
	)
SELECT
	PR.PRODUCT_ID,
	PR.PRODUCT_NAME,
	PR.REVENUE,
	ROUND(PR.REVENUE * 100.0 / T.TOTAL_REV, 2) AS REVENUE_SHARE_PCT
FROM
	PRODUCT_REVENUE PR
	CROSS JOIN TOTAL_REVENUE T
ORDER BY
	REVENUE_SHARE_PCT DESC;

--     29. Identify the top 3 best-performing products in each region
--     based on total revenue contribution.
--
--     Business Insight:
--     This analysis helps understand regional product preferences by ranking
--     products within each region using revenue as the performance metric.
--     It highlights which products drive sales in specific markets, enabling
--     region-specific marketing strategies, inventory planning, and product
--     optimization. This is useful for identifying localized demand patterns
--     and tailoring offerings to different geographic regions.
WITH
	CTE AS (
		SELECT
			C.REGION,
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			ROUND(
				SUM(
					OI.QUANTITY * P.UNIT_PRICE * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			CUSTOMERS1 C
			JOIN ORDERS1 O ON C.CUSTOMER_ID = O.CUSTOMER_ID
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.REGION,
			P.PRODUCT_ID,
			P.PRODUCT_NAME
	),
	RANKS AS (
		SELECT
			*,
			DENSE_RANK() OVER (
				PARTITION BY
					REGION
				ORDER BY
					TOTAL_REVENUE DESC
			) AS RNK
		FROM
			CTE
	)
SELECT
	*
FROM
	RANKS
WHERE
	RNK <= 3
	--     30. Revenue Anomaly Detection (Z-score Method)
	--     Purpose: Identify months where revenue significantly deviates from
	--     normal patterns using statistical measures (mean and standard deviation).
	--
	--     Business Insight:
	--     This analysis calculates monthly revenue and compares each value against
	--     the overall average revenue using Z-score. Months with a Z-score greater
	--     than or equal to ±2 are flagged as anomalies, indicating unusual spikes
	--     or drops in business performance. This helps detect unexpected demand
	--     changes, campaign impacts, seasonal effects, or potential data issues,
	--     enabling proactive business decision-making and investigation.
WITH
	MONTHLY_REVENUE AS (
		SELECT
			DATE_TRUNC('month', O.ORDER_DATE)::DATE AS MONTH,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS REVENUE
		FROM
			ORDERS1 O
			JOIN ORDER_ITEMS1 OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS1 P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			DATE_TRUNC('month', O.ORDER_DATE)
	),
	STATS AS (
		SELECT
			MONTH,
			REVENUE,
			AVG(REVENUE) OVER () AS AVG_REVENUE,
			STDDEV(REVENUE) OVER () AS STD_REVENUE
		FROM
			MONTHLY_REVENUE
	)
SELECT
	MONTH,
	REVENUE,
	ROUND(AVG_REVENUE, 2) AS AVG_REVENUE,
	ROUND(STD_REVENUE, 2) AS STD_REVENUE,
	ROUND(
		(REVENUE - AVG_REVENUE) / NULLIF(STD_REVENUE, 0),
		2
	) AS Z_SCORE,
	CASE
		WHEN ABS((REVENUE - AVG_REVENUE) / NULLIF(STD_REVENUE, 0)) >= 2 THEN 'Anomaly'
		ELSE 'Normal'
	END AS STATUS
FROM
	STATS
ORDER BY
	MONTH;





















	