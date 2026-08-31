Python 
        │
        ▼
   5 CSV files (raw_data/)
        │
        ▼
MySQL: flipkart_oltp  (OLTP — normalized, transactional)
   ├── user_info
   ├── order_info
   ├── payment_info
   ├── logistic_info
   └── rating_review
        │
        ▼  (Python ETL: etl_pipeline.py)
        │  Extract → Transform → Load
        ▼
PostgreSQL: flipkart_dwh  (OLAP — Star Schema)
   ├── fact_orders          (Fact table — measures)
   ├── dim_user             (Dimension)
   ├── dim_product          (Dimension)
   ├── dim_date             (Dimension)
   ├── dim_payment          (Dimension)
   └── dim_logistic         (Dimension)




# Flipkart-style E-Commerce Data Warehouse & SQL Analysis Project

**A complete end-to-end Data Engineering + Data Analytics project** — built using Python, MySQL, and PostgreSQL — designed to teach *why SQL matters* through a real-world workflow.

---

## 📌 Project Overview

Yeh project simulate karta hai ki Flipkart jaisi e-commerce company apna raw transactional data kaise process karti hai — usse ek analytics-ready Data Warehouse banati hai, aur phir SQL se business-critical insights nikalti hai.

**Tech Stack:**
| Layer | Technology |
|---|---|
| Raw Data Generation | Python (`Faker` library) |
| OLTP Database (Transactional) | MySQL |
| OLAP Data Warehouse (Analytical) | PostgreSQL |
| ETL Pipeline | Python (`mysql-connector-python`, `psycopg2`) |
| Analysis | SQL (PostgreSQL) |

**Data Volume:** 3 years of data (Aug 2023 – Aug 2026), ~44,000 records across 5 raw tables.

---

## 🎯 Why This Project? (The "Why SQL" Motivation)

Companies collect huge amounts of raw transactional data — orders, payments, deliveries, reviews. But this raw data, sitting in normalized tables, is **hard to analyze directly**. This project shows the full journey:

```
Raw messy transactional data → Organized Data Warehouse → SQL-powered business answers
```

By the end, you'll understand not just SQL syntax, but *why* companies structure their data this way before running analytics.

---

## 🏗️ Project Architecture

```
Python (generate_data.py)
        │
        ▼
   5 CSV files (raw_data/)
        │
        ▼
MySQL: flipkart_oltp  (OLTP — normalized, transactional)
   ├── user_info
   ├── order_info
   ├── payment_info
   ├── logistic_info
   └── rating_review
        │
        ▼  (Python ETL: etl_pipeline.py)
        │  Extract → Transform → Load
        ▼
PostgreSQL: flipkart_dwh  (OLAP — Star Schema)
   ├── fact_orders          (Fact table — measures)
   ├── dim_user             (Dimension)
   ├── dim_product          (Dimension)
   ├── dim_date             (Dimension)
   ├── dim_payment          (Dimension)
   └── dim_logistic         (Dimension)
        │
        ▼
10 SQL Analysis Queries (sql/03_analysis_queries.sql)
   → Business Insights
```

---

## 📁 Folder Structure

```
flipkart_dwh_project/
├── venv/                          (your Python virtual environment)
├── requirements.txt                (Python package dependencies)
├── raw_data/                       (Generated CSV files)
│   ├── user_info.csv
│   ├── order_info.csv
│   ├── payment_info.csv
│   ├── logistic_info.csv
│   └── rating_review.csv
├── python/
│   ├── generate_data.py            (Step 2: generates raw CSV data)
│   ├── load_oltp.py                (Step 3: CSV → MySQL)
│   └── etl_pipeline.py             (Step 5: MySQL → PostgreSQL)
├── sql/
│   ├── 01_create_oltp_schema.sql   (Step 3: MySQL table definitions)
│   ├── 02_create_dwh_schema.sql    (Step 4: PostgreSQL Star Schema)
│   └── 03_analysis_queries.sql     (Step 6: 10 business queries)
└── docs/                           (Step-by-step written records)
    ├── step1_business_problem.md
    ├── step2_raw_data_generation.md
    ├── step3_oltp_database_setup.md
    ├── step4_star_schema_design.md
    ├── step5_etl_pipeline.md
    └── step6_sql_analysis_queries.md
```

---

## 🚀 How to Reproduce This Project (Full Setup Guide)

### Prerequisites
- Python 3.10+
- MySQL Server (8.0+)
- PostgreSQL (14+)
- VS Code (recommended)

### Step 0: Environment Setup
```bash
# Create and activate virtual environment
python -m venv venv

# Windows
venv\Scripts\activate
# Mac/Linux
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

`requirements.txt` contains:
```
faker==22.6.0
mysql-connector-python==8.3.0
psycopg2-binary==2.9.9
```

---

### Step 1: Business Problem (No code — see `docs/step1_business_problem.md`)
Understand the "why" before touching any code. Flipkart's analytics team needs answers to questions like: which products sell best, which cities are most profitable, where are deliveries slow, etc.

---

### Step 2: Generate Raw Data
```bash
python python/generate_data.py
```
This creates 5 CSV files inside `raw_data/` — ~44,000 realistic records spanning 3 years, with logical business rules built in (e.g., cancelled orders have no delivery date).

---

### Step 3: Setup MySQL OLTP Database
```bash
# 1. Create schema (creates database + 5 tables with PK/FK constraints)
mysql -u root -p < sql/01_create_oltp_schema.sql

# 2. Update credentials in python/load_oltp.py (DB_CONFIG section)

# 3. Load CSV data into MySQL
python python/load_oltp.py
```
Expected: 44,492 rows loaded across 5 tables.

---

### Step 4: Setup PostgreSQL Data Warehouse (Star Schema)
```bash
# 1. Create the warehouse database
psql -U postgres -c "CREATE DATABASE flipkart_dwh;"

# correct for me

"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE DATABASE flipkart_dwh;"

# 2. Create Star Schema (1 Fact table + 5 Dimension tables)
psql -U postgres -d flipkart_dwh -f sql/02_create_dwh_schema.sql

# this is for my system and run in venv cmd

"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d flipkart_dwh -f sql\02_create_dwh_schema.sql

# 3. Verify
psql -U postgres -d flipkart_dwh -c "\dt"

Expected: 6 tables — `fact_orders`, `dim_user`, `dim_product`, `dim_date`, `dim_payment`, `dim_logistic`.

# this is for my system

"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d flipkart_dwh -c "\dt"


### Step 5: Run the ETL Pipeline (MySQL → PostgreSQL)
```bash
# 1. Update credentials in python/etl_pipeline.py
#    (MYSQL_CONFIG and POSTGRES_CONFIG sections)

# 2. Run the pipeline
python python/etl_pipeline.py
```
This extracts data from MySQL, transforms it (deduplication, date-parsing, age-group derivation), and loads it into the PostgreSQL Star Schema. Expected: 12,000 fact rows loaded.

---

### Step 6: Run the 10 SQL Analysis Queries
```bash
psql -U postgres -d flipkart_dwh -f sql/03_analysis_queries.sql
```

 # for my system run in venv

"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d flipkart_dwh -f sql\03_analysis_queries.sql


Or open `sql/03_analysis_queries.sql` in pgAdmin/DBeaver and run each query individually to study the output.

| # | Query | SQL Concept |
|---|---|---|
| 1 | Top 10 revenue-generating products | Basic SELECT, GROUP BY, ORDER BY |
| 2 | City-wise revenue & avg order value | Aggregates |
| 3 | Customer order history | JOIN |
| 4 | Payment mode vs delivery status | Multi-table JOIN |
| 5 | High-value customers | Subquery |
| 6 | Monthly running total revenue | Window Function |
| 7 | Delivery speed categorization | CASE WHEN |
| 8 | Low-rated categories | HAVING |
| 9 | Monthly order trend | Date functions |
| 10 | Best-selling product per city | CTE + RANK() |

---

## 🧠 Key Concepts Learned

| Concept | Where It's Used |
|---|---|
| OLTP vs OLAP | Steps 3 & 4 — two different database designs for two different purposes |
| Star Schema (Fact/Dimension) | Step 4 |
| ETL (Extract-Transform-Load) | Step 5 |
| Surrogate Keys vs Natural Keys | `user_key` (PostgreSQL) vs `user_id` (MySQL) |
| Cross-database integration | Python connecting MySQL + PostgreSQL together |
| SQL JOINs, Aggregates, Subqueries, Window Functions, CTEs | Step 6 |

---

## 📊 Sample Insights Discovered

- **Top category**: Electronics dominates top-revenue products (Bluetooth Earbuds, Smartwatches)
- **Best market**: Amritsar has the highest average order value
- **Delivery**: ~20% of orders fall into "Slow" delivery (avg 7.6 days)
- **Quality flag**: Sports & Fitness category has average rating right at the 3.5 threshold
- **Growth trend**: Revenue shows consistent month-over-month growth from Sep 2023 onward

---
