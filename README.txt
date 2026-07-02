# 📊 B2B SaaS Customer & Revenue Analytics — SQL Portfolio Project

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?logo=postgresql)
![SQL](https://img.shields.io/badge/SQL-Advanced-lightgrey?logo=database)
![Project](https://img.shields.io/badge/Project-B2B%20Analytics-brightgreen)
![Data](https://img.shields.io/badge/Data-Synthetic-orange)
![License](https://img.shields.io/badge/License-MIT-lightblue)

**Author:** Anshul
**Database:** PostgreSQL 18.3
**Dataset:** Synthetic B2B SaaS platform (self-generated)
**Scope:** 1,000 customers · 10,000 orders · 50,000 order line items · 15,000 activity logs

---

## 📌 Project Snapshot

* End-to-end SQL analytics project built entirely in PostgreSQL
* Designed and generated a fully reproducible synthetic B2B SaaS dataset
* 1,000 customers, 10,000 orders, 50,000 order items, and 15,000 activity records
* 29 business-focused analytical SQL queries
* Covers customer segmentation, revenue analytics, retention, churn, cohort analysis, market basket analysis, and anomaly detection
* Demonstrates advanced SQL using CTEs, window functions, statistical analysis, and data modeling

---

## About This Project

This project started with a simple question I ask myself before every analysis: *if this were a real SaaS company, what would the founder or the VP of Sales actually want to know?*

So instead of just running a handful of `SELECT` statements on a clean, tidy dataset, I built the whole thing from the ground up — schema, relationships, and a synthetic dataset that deliberately includes the kind of mess you find in real production data (missing login counts, missing satisfaction scores, missing support ticket counts, all injected at realistic rates). Then I wrote 29 analytical queries that walk through the full lifecycle of a B2B customer: acquisition, channel performance, product mix, purchasing behavior, retention, churn, and anomaly detection.

The goal wasn't to show off every SQL keyword I know. It was to answer the questions a data analyst actually gets asked in a stand-up meeting — *"Which channel is underperforming?" "Who are we about to lose?" "What happened in June?"* — and answer them with a clear business purpose behind every query.

---

## Why This Dataset

Real SaaS/B2B transactional data is rarely available for public portfolios, and using a Kaggle CSV felt too easy—most of the difficult work in that scenario is already done. Instead, I generated the dataset directly in PostgreSQL using `GENERATE_SERIES`, `RANDOM()`, and `SETSEED(0.42)` to make the results fully reproducible.

This required designing:

* A realistic **star-schema** database
* Business logic where revenue is calculated as `quantity × unit price × (1 − discount %)`
* Intentional data quality issues (10–20% NULLs in engagement fields) to simulate real production datasets

The result is a project that demonstrates not only SQL proficiency but also data modeling and analytical thinking.

---

## Entity Relationship Overview

```text
CUSTOMERS1 ──┬──< ORDERS1 ──< ORDER_ITEMS1 >── PRODUCTS1
             │
             └──< CUSTOMER_ACTIVITY1
```

| Table                | Grain                        | Purpose                                                          |
| -------------------- | ---------------------------- | ---------------------------------------------------------------- |
| `CUSTOMERS1`         | One row per customer         | Firmographics, region, industry, annual revenue, account manager |
| `PRODUCTS1`          | One row per product          | 20 SaaS products across multiple business categories             |
| `ORDERS1`            | One row per order            | Order header, order date, customer, sales channel                |
| `ORDER_ITEMS1`       | One row per order line       | Product quantity, pricing, discount, revenue calculation         |
| `CUSTOMER_ACTIVITY1` | One row per monthly activity | Logins, support tickets, satisfaction score, engagement metrics  |

---

## Business Questions Answered

The project contains **30 analytical SQL queries**, grouped into real-world business themes.

### Customer & Market Overview

* Customer distribution by region and industry
* Customers who registered but never placed an order

### Revenue & Channel Performance

* Revenue by sales channel
* Average Order Value (AOV)
* Monthly revenue trends
* Month-over-Month growth
* Revenue by product category

### Customer Value & Segmentation

* RFM analysis
* Customer lifetime revenue
* Top customers
* Revenue contribution
* NTILE-based customer segmentation

### Retention, Engagement & Churn

* Monthly active customers
* Repeat purchase analysis
* Month-1 → Month-2 retention
* Churn and at-risk customer identification
* Customer inactivity analysis

### Product & Advanced Analytics

* Best-selling products
* Product revenue contribution
* Market basket analysis
* Pareto (80/20) analysis
* Purchase frequency segmentation
* Regional product performance
* Z-score anomaly detection

Every query begins with a comment describing the business question it answers before presenting the SQL solution.

---

## Key Insights

| Metric                               |                                                              Value |
| ------------------------------------ | -----------------------------------------------------------------: |
| Average Monthly Revenue              |                                                         **$20.1M** |
| Top Revenue Channel                  |                                               **Online ($156.0M)** |
| Highest AOV Channel                  |                                         **Direct Sales ($61,853)** |
| Top Customer by Revenue              |                                          **Customer_861 ($1.50M)** |
| Fraud Detection Engine Revenue Share |                                                         **11.89%** |
| Active Customers                     |                                                            **638** |
| At-Risk Customers                    |                                                             **42** |
| Churned Customers                    |                                                            **320** |
| Average Retention Rate               |                                                         **27.46%** |
| Customers Inactive 6+ Months         |                                                            **115** |
| Above-Average Revenue Customers      |                                                            **476** |
| Top Basket Pair                      | **Email Campaign Pro + Customer Insights AI (709 co-occurrences)** |
| Revenue Anomaly                      |                                     **June 2024 (Z-score: −3.12)** |

### Business Interpretation

* Customer retention is the largest business challenge. Only **638 of roughly 1,000 customers remain active**, while **320 have already churned**.
* **42 customers** are currently classified as at risk, providing an opportunity for proactive retention campaigns.
* **Online** generates the highest total revenue, while **Direct Sales** produces the highest Average Order Value, suggesting different optimization strategies for each sales channel.
* **Fraud Detection Engine** contributes nearly **12% of total company revenue**, making it the strongest individual product for future investment and cross-selling.
* A statistically significant revenue anomaly occurred in **June 2024 (Z-score −3.12)**, indicating a month that deserves further operational investigation.

---

## Skills Demonstrated

| Category               | Techniques                                                     |
| ---------------------- | -------------------------------------------------------------- |
| Data Modeling          | Star schema, primary keys, foreign keys, referential integrity |
| Data Generation        | `GENERATE_SERIES`, `RANDOM()`, `SETSEED()`                     |
| SQL Analytics          | `GROUP BY`, `HAVING`, aggregation, joins                       |
| Window Functions       | `LAG`, `NTILE`, `DENSE_RANK`, running totals, rolling averages |
| Query Design           | CTEs, nested queries, modular SQL                              |
| Business Analytics     | RFM, churn analysis, cohort retention, Pareto analysis         |
| Statistics             | Z-score anomaly detection using `AVG()` and `STDDEV()`         |
| Market Basket Analysis | Self-joins and co-occurrence analysis                          |
| Data Quality           | `COALESCE`, `NULLIF`, NULL-aware aggregations                  |

---

## How to Run

1. Install PostgreSQL (v13 or newer).
2. Create a new database.
3. Execute `analysis.sql`.

```bash
psql -U your_username -d your_database -f analysis.sql
```

The project uses `SETSEED(0.42)` to generate a reproducible synthetic dataset, allowing the published metrics to be reproduced consistently.

---

## Project Structure

```text
├── README.md
├── analysis.sql
└── LICENSE
```

---

## About the Dataset

The dataset is entirely synthetic and was created specifically for portfolio purposes. It contains no real customer information or proprietary business data.

The objective was to simulate realistic B2B SaaS transactional data while demonstrating practical SQL techniques, business analysis, and data modeling skills in a fully shareable project.



## 👤 Author
**Anshul**
Aspiring Data Analyst | Python · SQL · Power BI
📧 [1311anshul@gmail.com] | 🔗 [LinkedIn](https://www.linkedin.com/in/anshuljangra4/) 
