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
