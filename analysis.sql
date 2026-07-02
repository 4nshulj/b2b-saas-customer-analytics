
DROP TABLE IF EXISTS ORDER_ITEMS CASCADE;

DROP TABLE IF EXISTS ORDERS CASCADE;

DROP TABLE IF EXISTS PRODUCTS CASCADE;

DROP TABLE IF EXISTS CUSTOMERS CASCADE;

-- -----------------------------------------------------------
-- Dimension: CUSTOMERS
-- Captures firmographic data — region, industry, revenue tier,
-- and the assigned account manager for each B2B client.
-- -----------------------------------------------------------
CREATE TABLE CUSTOMERS (
	CUSTOMERS_ID INT PRIMARY KEY,
	CUSTOMERS_NAME VARCHAR(100),
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
CREATE TABLE PRODUCTS (
	PRODUCT_ID INT PRIMARY KEY,
	PRODUCT_NAME VARCHAR(100),
	CATEGORY VARCHAR(50),
	UNIT_PRICE DECIMAL(10, 2)
);

-- -----------------------------------------------------------
-- Fact: Orders
-- One row per transaction header; captures the sales channel
-- through which the CUSTOMERS placed the order.
-- -----------------------------------------------------------
CREATE TABLE ORDERS (
	ORDER_ID INT PRIMARY KEY,
	CUSTOMERS_ID INT,
	ORDER_DATE DATE,
	SALES_CHANNEL VARCHAR(50),
	CONSTRAINT FK_ORDERS_CUSTOMERS FOREIGN KEY (CUSTOMERS_ID) REFERENCES CUSTOMERS (CUSTOMERS_ID)
);

-- -----------------------------------------------------------
-- Fact: Order Items
-- Line-level detail — product, quantity, and discount applied.
-- Revenue = quantity × unit_price × (1 − discount_pct / 100)
-- -----------------------------------------------------------
CREATE TABLE ORDER_ITEMS (
	ORDER_ITEM_ID INT PRIMARY KEY,
	ORDER_ID INT,
	PRODUCT_ID INT,
	QUANTITY INT,
	DISCOUNT_PCT DECIMAL(5, 2),
	CONSTRAINT FK_ORDERITEMS_ORDER FOREIGN KEY (ORDER_ID) REFERENCES ORDERS (ORDER_ID),
	CONSTRAINT FK_ORDERITEMS_PRODUCT FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS (PRODUCT_ID)
);

-- -----------------------------------------------------------
-- Fact: CUSTOMERS Activity
-- Monthly engagement signals — logins, support tickets, and
-- satisfaction scores. Used for churn-risk scoring.
-- -----------------------------------------------------------
CREATE TABLE CUSTOMERS_ACTIVITY1 (
	ACTIVITY_ID INT PRIMARY KEY,
	CUSTOMERS_ID INT,
	ACTIVITY_DATE DATE,
	LOGIN_COUNT INT,
	SUPPORT_TICKETS INT,
	SATISFACTION_SCORE DECIMAL(3, 1),
	CONSTRAINT FK_ACTIVITY_CUSTOMERS FOREIGN KEY (CUSTOMERS_ID) REFERENCES CUSTOMERS (CUSTOMERS_ID)
);

-- -----------------------------------------------------------
-- Seed Data: Products (20 SKUs across 6 categories)
-- -----------------------------------------------------------
INSERT INTO
	PRODUCTS
VALUES
	(1, 'CRM Enterprise', 'Software', 1200),
	(2, 'CRM Starter', 'Software', 300),
	(3, 'Cloud Storage 1TB', 'Cloud', 120),
	(4, 'Cloud Storage 10TB', 'Cloud', 950),
	(5, 'Data Analytics Suite', 'Analytics', 1800),
	(6, 'BI Dashboard Pro', 'Analytics', 750),
	(7, 'Marketing Automation', 'Marketing', 650),
	(8, 'Email Campaign Pro', 'Marketing', 220),
	(9, 'CUSTOMERS Support AI', 'Support', 1400),
	(10, 'Chatbot Enterprise', 'Support', 900),
	(11, 'Fraud Detection Engine', 'Finance', 2500),
	(12, 'Risk Monitoring Suite', 'Finance', 1700),
	(13, 'HR Payroll Pro', 'HR', 850),
	(14, 'Talent Analytics', 'HR', 650),
	(15, 'Inventory Optimizer', 'Operations', 1400),
	(16, 'Supply Chain Tracker', 'Operations', 1600),
	(17, 'CUSTOMERS Insights AI', 'Analytics', 2200),
	(18, 'Advanced Reporting', 'Analytics', 500),
	(19, 'Campaign Intelligence', 'Marketing', 950),
	(20, 'Service Desk Premium', 'Support', 1200);

-- -----------------------------------------------------------
-- Seed Data: 1,000 synthetic CUSTOMERS
-- -----------------------------------------------------------
INSERT INTO
	CUSTOMERS
SELECT
	GS,
	'CUSTOMERS_' || GS,
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
	ORDERS
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
	ORDER_ITEMS
SELECT
	GS,
	FLOOR(RANDOM() * 10000 + 1)::INT,
	FLOOR(RANDOM() * 20 + 1)::INT,
	FLOOR(RANDOM() * 25 + 1)::INT,
	ROUND((RANDOM() * 30)::NUMERIC, 2)
FROM
	GENERATE_SERIES(1, 50000) GS;

-- -----------------------------------------------------------
-- Seed Data: 15,000 CUSTOMERS activity records (2023 – 2024)
-- NULLs are intentionally injected (~10–20 %) to simulate
-- real-world data quality issues.
-- -----------------------------------------------------------
INSERT INTO
	CUSTOMERS_ACTIVITY1
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
	'CUSTOMERS' AS TABLE_NAME,
	COUNT(*) AS ROW_COUNT
FROM
	CUSTOMERS
UNION ALL
SELECT
	'PRODUCTS',
	COUNT(*)
FROM
	PRODUCTS
UNION ALL
SELECT
	'ORDERS',
	COUNT(*)
FROM
	ORDERS
UNION ALL
SELECT
	'ORDER_ITEMS',
	COUNT(*)
FROM
	ORDER_ITEMS
UNION ALL
SELECT
	'CUSTOMERS_activity1',
	COUNT(*)
FROM
	CUSTOMERS_ACTIVITY1;




-- 1.  Preview the first 10 CUSTOMERS
--      Quick sanity check — confirm columns, data types, and
--      that no obvious data corruption exists.
SELECT
	*
FROM
	CUSTOMERS
LIMIT
	10;

-- 2.  Distribution of CUSTOMERS by region
--      Understand the geographic spread of the CUSTOMERS base.
--      Useful for deciding where to prioritise sales resources.
SELECT
	REGION,
	COUNT(*) AS TOTAL_CUSTOMERS
FROM
	CUSTOMERS
GROUP BY
	REGION
ORDER BY
	TOTAL_CUSTOMERS DESC;

-- 3.  Distribution of CUSTOMERS by industry
--      Identifies which verticals drive the most accounts —
--      critical for persona-based marketing.
SELECT
	INDUSTRY,
	COUNT(*) AS TOTAL_CUSTOMERS
FROM
	CUSTOMERS
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
	ORDERS O
	JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
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
	ORDERS O
	JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
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
	ORDERS O
	JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY
	P.CATEGORY
	-- 7. CUSTOMERS with No Orders
	--    Purpose: Identify CUSTOMERS who have registered but have not
	--    placed any orders.
	--
	--    Business Insight:
	--    These CUSTOMERS represent non-converting users and provide
	--    an opportunity for targeted onboarding, engagement, and
	--    activation strategies to improve conversion rates.
SELECT
	C.CUSTOMERS_ID,
	C.CUSTOMERS_NAME,
	C.REGION,
	C.INDUSTRY,
	C.SIGNUP_DATE
FROM
	CUSTOMERS C
	LEFT JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
WHERE
	O.ORDER_ID IS NULL
GROUP BY
	C.CUSTOMERS_ID
	-- 8. RFM Analysis (Recency, Frequency, Monetary)
	--    Purpose: Segment CUSTOMERS based on purchasing behavior using RFM metrics.
	--
	--    RFM Components:
	--      - Recency: Days since last purchase (calculated using dataset max order_date)
	--      - Frequency: Total number of orders placed by each CUSTOMERS
	--      - Monetary: Total revenue generated by each CUSTOMERS
	--
	--    Business Insight:
	--    This segmentation helps identify:
	--      - High-value loyal CUSTOMERS (Champions)
	--      - At-risk CUSTOMERS with declining engagement
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
			ORDERS
	)
SELECT
	C.CUSTOMERS_ID,
	C.CUSTOMERS_NAME,
	(R.REF_DATE - MAX(O.ORDER_DATE)) AS RECENECY_DAYS,
	COUNT(DISTINCT O.ORDER_ID) AS FREQUENCY,
	SUM(C.ANNUAL_REVENUE) AS MONETARY
FROM
	CUSTOMERS C
	LEFT JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
	CROSS JOIN REFERENCE_DATE R
GROUP BY
	C.CUSTOMERS_ID,
	C.CUSTOMERS_NAME,
	R.REF_DATE
	-- 9. Above Average Revenue CUSTOMERS
	--    Purpose: Identify CUSTOMERS whose total revenue contribution
	--    exceeds the overall average CUSTOMERS revenue.
	--
	--    Business Insight:
	--    These CUSTOMERS represent high-value accounts and should be
	--    prioritized for retention strategies, upselling opportunities,
	--    and enhanced account management focus.
WITH
	CUSTOMERS_REVENUE AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			C.REGION,
			C.INDUSTRY,
			ROUND(
				SUM(
					OI.QUANTITY * P.UNIT_PRICE * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			C.REGION,
			C.INDUSTRY
	)
SELECT
	*
FROM
	CUSTOMERS_REVENUE
WHERE
	TOTAL_REVENUE > (
		SELECT
			AVG(TOTAL_REVENUE)
		FROM
			CUSTOMERS_REVENUE
	)
ORDER BY
	TOTAL_REVENUE DESC;

-- 10. Top CUSTOMERS by Revenue
--     Purpose: Identify and rank CUSTOMERS based on total revenue contribution.
--
--     Business Insight:
--     This analysis highlights the most valuable CUSTOMERS, enabling
--     targeted retention strategies, personalized engagement, and
--     strategic account management to maximize long-term value.
WITH
	CTE AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS TOTAL_REVENUE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
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
	CUSTOMERS_ID,
	CUSTOMERS_NAME,
	TOTAL_REVENUE
FROM
	RANKS
WHERE
	RNK <= 10
	-- 11. CUSTOMERS Revenue Share (%)
	--     Purpose: Calculate each CUSTOMERS's contribution as a percentage
	--     of total revenue.
	--
	--     Business Insight:
	--     This helps identify revenue concentration, key accounts driving
	--     business performance, and potential dependency risks on top
	--     CUSTOMERS.
WITH
	CTE AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS CUSTOMERS_REVENUE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
	),
	REVENUE_SHARE AS (
		SELECT
			*,
			SUM(CUSTOMERS_REVENUE) OVER () AS TOTAL_REVENUE
		FROM
			CTE
	)
SELECT
	*,
	ROUND(CUSTOMERS_REVENUE * 100.0 / TOTAL_REVENUE, 2) AS REVENUE_SHARE_PCT
FROM
	REVENUE_SHARE
	-- 12. NTILE(5) — CUSTOMERS Segmentation Logic
	-- Purpose: Segment CUSTOMERS into five equal-sized groups based on
	-- total revenue, ranked from highest to lowest.
	--
	-- How it works:
	--   - CUSTOMERS are ordered by total revenue (descending)
	--   - Data is divided into 5 approximately equal buckets
	--   - Each bucket is assigned a value from 1 to 5:
	--       1 → Top 20% (highest-value CUSTOMERS)
	--       5 → Bottom 20% (lowest-value CUSTOMERS)
	--
	-- Business Use:
	-- This segmentation supports CUSTOMERS Lifetime Value (CLV) analysis,
	-- enabling identification of VIP CUSTOMERS, growth opportunities,
	-- and low-value segments for targeted marketing and retention strategies.
WITH
	CUSTOMERS_METRICS AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
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
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
	),
	RANKED_CUSTOMERS AS (
		SELECT
			*,
			NTILE(5) OVER (
				ORDER BY
					TOTAL_REVENUE DESC
			) AS TILE
		FROM
			CUSTOMERS_METRICS
	)
SELECT
	CUSTOMERS_ID,
	CUSTOMERS_NAME,
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
	ORDERS O
	JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
	JOIN PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
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
			ORDERS O
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON P.PRODUCT_ID = OI.PRODUCT_ID
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
	-- 15. Top CUSTOMERS by Revenue Share (%)
	--     Purpose: Identify CUSTOMERS contributing the highest share
	--     of total company revenue.
	--
	--     Business Insight:
	--     This helps evaluate revenue concentration risk and highlights
	--     key accounts that are critical for business stability and
	--     long-term growth.
WITH
	CTE AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			ROUND(
				SUM(
					P.UNIT_PRICE * OI.QUANTITY * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS CUSTOMERS_REVENUE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
	),
	REVENUE_SHARE AS (
		SELECT
			*,
			SUM(CUSTOMERS_REVENUE) OVER () AS TOTAL_REVENUE
		FROM
			CTE
	),
	RANKS AS (
		SELECT
			*,
			ROUND(CUSTOMERS_REVENUE * 100.0 / TOTAL_REVENUE, 2) AS REVENUE_SHARE_PCT,
			DENSE_RANK() OVER (
				ORDER BY
					ROUND(CUSTOMERS_REVENUE * 100.0 / TOTAL_REVENUE, 2) DESC
			) AS RNK
		FROM
			REVENUE_SHARE
	)
SELECT
	RNK,
	CUSTOMERS_ID,
	CUSTOMERS_NAME,
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
			ORDERS O
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
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
	-- 17. Monthly Active CUSTOMERS
	--     Purpose: Count unique CUSTOMERS who placed at least one order
	--     in each month.
	--
	--     Business Insight:
	--     This metric helps track CUSTOMERS engagement trends over time
	--     and provides insight into user retention and platform activity.
SELECT
	DATE_TRUNC('month', ORDER_DATE)::DATE AS MONTH,
	COUNT(DISTINCT CUSTOMERS_ID) AS ACTIVE_CUSTOMERS
FROM
	ORDERS
GROUP BY
	DATE_TRUNC('month', ORDER_DATE)
ORDER BY
	MONTH;

-- 18. Repeat CUSTOMERS per Month
--     Purpose: Identify and count CUSTOMERS who placed more than
--     one order within the same month.
--
--     Business Insight:
--     This metric helps evaluate CUSTOMERS loyalty and engagement
--     by highlighting repeat purchasing behavior over time.
WITH
	CUSTOMERS_MONTHLY_ORDERS AS (
		SELECT
			DATE_TRUNC('month', ORDER_DATE)::DATE AS MONTH,
			CUSTOMERS_ID,
			COUNT(ORDER_ID) AS ORDER_COUNT
		FROM
			ORDERS
		GROUP BY
			DATE_TRUNC('month', ORDER_DATE),
			CUSTOMERS_ID
	)
SELECT
	MONTH,
	COUNT(CUSTOMERS_ID) AS REPEAT_CUSTOMERS
FROM
	CUSTOMERS_MONTHLY_ORDERS
WHERE
	ORDER_COUNT > 1
GROUP BY
	MONTH
ORDER BY
	MONTH;

-- 19. Month 1 to Month 2 CUSTOMERS Retention (COUNT)
--     Purpose: Identify CUSTOMERS who made a purchase in a given month
--     and returned to make another purchase in the following month.
--
--     Business Insight:
--     This metric measures early CUSTOMERS stickiness and engagement behavior,
--     serving as a key indicator of product adoption and potential churn risk.
--
--     Metric Type:
--     Absolute retention (raw CUSTOMERS count, not percentage)
WITH
	CTE AS (
		SELECT
			CUSTOMERS_ID,
			DATE_TRUNC('Month', ORDER_DATE) AS MONTH
		FROM
			ORDERS
		GROUP BY
			CUSTOMERS_ID,
			DATE_TRUNC('Month', ORDER_DATE)
	),
	RETAINED AS (
		SELECT
			A.MONTH AS CURRENT_MONTH,
			COUNT(DISTINCT A.CUSTOMERS_ID) AS RETAINED_CUSTOMERS
		FROM
			CTE A
			JOIN CTE B ON A.CUSTOMERS_ID = B.CUSTOMERS_ID
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
	--     Purpose: Measure the percentage of CUSTOMERS who return
	--     and make a purchase in the subsequent month.
	--
	--     Business Insight:
	--     This is a key retention KPI that indicates product stickiness,
	--     CUSTOMERS satisfaction, and early-stage churn behavior.
WITH
	MONTHLY_CUSTOMERS AS (
		SELECT
			CUSTOMERS_ID,
			DATE_TRUNC('month', ORDER_DATE)::DATE AS MONTH
		FROM
			ORDERS
		GROUP BY
			CUSTOMERS_ID,
			DATE_TRUNC('month', ORDER_DATE)
	),
	RETAINED AS (
		SELECT
			A.MONTH AS CURRENT_MONTH,
			COUNT(DISTINCT A.CUSTOMERS_ID) AS RETAINED_CUSTOMERS
		FROM
			MONTHLY_CUSTOMERS A
			JOIN MONTHLY_CUSTOMERS B ON A.CUSTOMERS_ID = B.CUSTOMERS_ID
			AND B.MONTH = A.MONTH + INTERVAL '1 month'
		GROUP BY
			A.MONTH
	),
	TOTAL AS (
		SELECT
			MONTH AS CURRENT_MONTH,
			COUNT(DISTINCT CUSTOMERS_ID) AS TOTAL_CUSTOMERS
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

-- 21. Inactive CUSTOMERS (Dataset-based logic)
--     Purpose: Identify CUSTOMERS who have not placed any orders in the
--     last 6 months of the dataset's available time range.
--
--     Business Insight:
--     This analysis detects CUSTOMERS inactivity and potential churn using
--     the maximum order date present in the dataset as a reference point
--     instead of CURRENT_DATE. It helps identify CUSTOMERS who are no longer
--     engaged, enabling targeted retention strategies, re-engagement campaigns,
--     and churn reduction efforts in a static dataset environment.
WITH
	MAX_DATE AS (
		SELECT
			MAX(ORDER_DATE) AS MAX_ORDER_DATE
		FROM
			ORDERS
	),
	CUSTOMERS_LAST_ORDER AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			MAX(O.ORDER_DATE) AS LAST_ORDER_DATE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
	)
SELECT
	CLO.CUSTOMERS_ID,
	CLO.CUSTOMERS_NAME,
	CLO.LAST_ORDER_DATE
FROM
	CUSTOMERS_LAST_ORDER CLO
	CROSS JOIN MAX_DATE M
WHERE
	CLO.LAST_ORDER_DATE < (M.MAX_ORDER_DATE - INTERVAL '6 months')
ORDER BY
	CLO.LAST_ORDER_DATE;

-- 22. Top-Selling Products by Quantity
--     Purpose: Identify the products with the highest total units sold
--     across all CUSTOMERS orders.
--
--     Business Insight:
--     This analysis highlights the most popular products based on sales
--     volume rather than revenue. It helps support inventory planning,
--     demand forecasting, procurement decisions, and marketing strategies
--     by identifying products with consistently high CUSTOMERS demand.
WITH
	CTE AS (
		SELECT
			P.PRODUCT_ID,
			P.PRODUCT_NAME,
			P.CATEGORY,
			SUM(OI.QUANTITY) AS TOTAL_QUANTITY
		FROM
			PRODUCTS P
			JOIN ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
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
	-- A self-join is performed on ORDER_ITEMS using order_id to find products
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
	ORDER_ITEMS A
	JOIN ORDER_ITEMS B ON A.ORDER_ID = B.ORDER_ID
	AND A.PRODUCT_ID < B.PRODUCT_ID
	JOIN PRODUCTS P1 ON A.PRODUCT_ID = P1.PRODUCT_ID
	JOIN PRODUCTS P2 ON B.PRODUCT_ID = P2.PRODUCT_ID
GROUP BY
	P1.PRODUCT_NAME,
	P2.PRODUCT_NAME
ORDER BY
	BOUGHT_TOGETHER DESC
	-- 24. Pareto Analysis (80/20 Rule)
	--     Purpose: Identify how revenue is distributed across CUSTOMERS and
	--     determine whether a small percentage of CUSTOMERS contribute to
	--     the majority of total revenue.
	--
	--     Business Insight:
	--     This analysis applies the Pareto principle to CUSTOMERS revenue data.
	--     CUSTOMERS are ranked by revenue contribution, and a cumulative
	--     percentage is calculated to identify the point at which ~80% of
	--     total revenue is achieved. This helps in recognizing high-value
	--     CUSTOMERS, understanding revenue concentration risk, and guiding
	--     retention and upselling strategies.
WITH
	CTE AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			ROUND(
				SUM(
					OI.QUANTITY * P.UNIT_PRICE * (1 - COALESCE(OI.DISCOUNT_PCT, 0) / 100.0)
				),
				2
			) AS REVENUE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
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
	-- 25. CUSTOMERS Purchase Frequency Segmentation
	--     Purpose: Segment CUSTOMERS based on how frequently they place orders
	--     in order to understand engagement and buying behavior patterns.
	--
	--     Business Insight:
	--     This analysis classifies CUSTOMERS into High, Medium, and Low frequency
	--     segments based on total order count. It helps identify loyal CUSTOMERS
	--     (high engagement), occasional buyers, and low-engagement CUSTOMERS who
	--     may be at risk of churn. This segmentation supports targeted marketing,
	--     retention strategies, and CUSTOMERS lifecycle management.
WITH
	CUSTOMERS_ORDERS AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			COUNT(O.ORDER_ID) AS TOTAL_ORDERS
		FROM
			CUSTOMERS C
			LEFT JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME
	)
SELECT
	CUSTOMERS_ID,
	CUSTOMERS_NAME,
	TOTAL_ORDERS,
	CASE
		WHEN TOTAL_ORDERS >= 5 THEN 'High Frequency'
		WHEN TOTAL_ORDERS BETWEEN 2 AND 4  THEN 'Medium Frequency'
		ELSE 'Low Frequency'
	END AS FREQUENCY_SEGMENT
FROM
	CUSTOMERS_ORDERS
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
			ORDERS O
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
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

-- 27. CUSTOMERS Churn  Analysis
--     Purpose: Identify CUSTOMERS who have not made any purchases recently
--     based on the latest available order date in the dataset.
--
--     Business Insight:
--     This analysis calculates each CUSTOMERS's last purchase date and compares
--     it with the maximum order date in the dataset to compute inactivity duration.
--     CUSTOMERS are then segmented into Active, At Risk, and Churned categories
--     based on days of inactivity. This helps in understanding CUSTOMERS retention,
--     identifying churn risk, and supporting targeted win-back campaigns and
--     retention strategies.
WITH
	LAST_DATE AS (
		SELECT
			MAX(ORDER_DATE) AS LAST_DATE
		FROM
			ORDERS
	),
	CHURN_DAY AS (
		SELECT
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
			MAX(O.ORDER_DATE) AS LAST_PURCHASE_DATE,
			L.LAST_DATE - MAX(O.ORDER_DATE) AS DAYS_INACTIVE
		FROM
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			CROSS JOIN LAST_DATE L
		GROUP BY
			C.CUSTOMERS_ID,
			C.CUSTOMERS_NAME,
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
			PRODUCTS P
			JOIN ORDER_ITEMS OI ON P.PRODUCT_ID = OI.PRODUCT_ID
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
			CUSTOMERS C
			JOIN ORDERS O ON C.CUSTOMERS_ID = O.CUSTOMERS_ID
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
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
			ORDERS O
			JOIN ORDER_ITEMS OI ON O.ORDER_ID = OI.ORDER_ID
			JOIN PRODUCTS P ON OI.PRODUCT_ID = P.PRODUCT_ID
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
