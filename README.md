# Credit Risk Data Warehouse

An end-to-end SQL Server data engineering project built on the **Home Credit Default Risk** corpus. This repository transforms millions of raw, multi-relational loan, bureau, and payment records into a unified, analytics-ready **Customer 360 Analytical Base Table (ABT)** designed to power downstream business intelligence and future credit risk modeling projects.

---

## Table of Contents

1. [Project Overview](https://www.google.com/search?q=%23project-overview)
2. [System Architecture](https://www.google.com/search?q=%23system-architecture)
3. [Repository Structure](https://www.google.com/search?q=%23repository-structure)
4. [Data Engineering Challenges & Solutions](https://www.google.com/search?q=%23data-engineering-challenges--solutions)
5. [Gold Layer Feature Store](https://www.google.com/search?q=%23gold-layer-feature-store)
6. [Getting Started](https://www.google.com/search?q=%23getting-started)
7. [Roadmap](https://www.google.com/search?q=%23roadmap)
8. [Author & License](https://www.google.com/search?q=%23author--license)

---

## Project Overview

Financial risk analysis requires consolidating fragmented behavioral records into a single, reliable view of borrower creditworthiness. Built using **Microsoft SQL Server (T-SQL)** and the **Medallion Architecture**, this warehouse ingests seven relational source tables (spanning up to 24 million rows) and aggregates them into a strict **1-to-1 customer-level flat view** (`gold.vw_customer_credit_profile`) covering **307,511** unique applicants.

### Core Objectives

* **Automated Ingestion:** Build repeatable, fault-tolerant `BULK INSERT` pipelines with execution logging and `TRY...CATCH` error handling.
* **Data Quality & Key Integrity:** Audit relational keys across tables, resolve structural key offsets, and eliminate one-to-many row duplication.
* **Query Optimization:** Provision strategic Non-Clustered Covering Indexes on physical Silver tables to accelerate multi-million-row aggregations.
* **Analytics-Ready Foundation:** Deliver a clean, denormalized Customer 360 view that serves as the single source of truth for downstream BI dashboards and upcoming credit risk modeling.

---

## System Architecture

```text
+-----------------------------------------------------------------------------------+
|                            RAW SOURCE DATA (CSV FILES)                            |
|   application_train | bureau | bureau_balance | previous_application |            |
|   credit_card_balance | pos_cash_balance | installments_payments                  |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                        BRONZE LAYER (Raw Landing Zone)                            |
|  * Stored Procedure: bronze.load_bronze_layer                                     |
|  * Bulk-loaded as VARCHAR(255) to preserve raw state and prevent load failures    |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                   SILVER LAYER (Cleansed, Typed & Indexed)                        |
|  * Enforces strict SQL data types (INT, DECIMAL, FLOAT, VARCHAR)                  |
|  * Standardizes categorical values & handles sentinel codes (e.g., 365243)        |
|  * Non-Clustered Covering Indexes applied on SK_ID_CURR & SK_ID_BUREAU            |
+-----------------------------------------+-----------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                GOLD LAYER (Denormalized Customer 360 Flat Table)                  |
|  * View: gold.vw_customer_credit_profile                                          |
|  * Wide Analytical Base Table (ABT) / Feature Store (1 Row = 1 Customer)          |
|  * Zero runtime JOIN overhead for Power BI, SQL Analytics & ML Pipelines          |
+-----------------------------------------------------------------------------------+

```

---

## Repository Structure

```text
Credit-Risk-Data-Warehouse/
├── datasets/                     # Source Home Credit CSV files (excluded from git via .gitignore)
├── docs/
│   ├── data_architecture.png     # High-level Medallion Architecture diagram
│   ├── data_flow_diagram.png     # End-to-end ETL data movement and transformation flow
│   ├── er_diagram.png            # Source-to-Silver relational Entity-Relationship diagram
│   └── data_catalogue.md         # Complete 39-column Gold layer data dictionary & examples
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql        # Raw staging table definitions (VARCHAR(255))
│   │   └── proc_load_bronze.sql  # Automated BULK INSERT stored procedure with logging
│   ├── silver/
│   │   ├── ddl_silver.sql        # Cleansed, typed table schemas
│   │   ├── proc_load_silver.sql  # Data transformation, cleansing & standardization logic
│   │   └── idx_silver.sql        # Non-Clustered Covering Indexes for join/group optimization
│   └── gold/
│       └── view_gold_abt.sql     # Multi-stage CTE view: gold.vw_customer_credit_profile
└── README.md                     # Project documentation

```

---

## Data Engineering Challenges & Solutions

### 1. Resolving Multi-Level Bureau Bridging & Key Offsets

* **Challenge:** Unlike internal product tables (`credit_card_balance`, `pos_cash_balance`, `installments_payments`) which join directly to `application_train` via `SK_ID_CURR`, external credit history is split across `hc_bureau` and `hc_bureau_balance` (linked via `SK_ID_BUREAU`). Empirical completeness checks (`INTERSECT` / `EXCEPT`) also revealed source-level key alignment anomalies, and naive joins caused row counts to double from 307,511 to 615,022.
* **Solution:** Implemented a two-stage CTE aggregation pipeline:
1. Pre-aggregated monthly payment statuses in `hc_bureau_balance` up to the individual loan level (`SK_ID_BUREAU`).
2. Bridged loan-level metrics into `hc_bureau` and grouped strictly by `SK_ID_CURR` before left-joining to the master application table, enforcing an exact 1-to-1 customer grain (307,511 rows).



### 2. Performance Tuning on Multi-Million-Row Tables

* **Challenge:** Grouping and joining tables containing up to 24 million rows created heavy table-scan bottlenecks when querying the Gold view.
* **Solution:** Created Non-Clustered Covering Indexes (`INCLUDE` clauses) on the physical Silver tables (`SK_ID_CURR` and `SK_ID_BUREAU`), enabling SQL Server's query optimizer to execute fast index seeks.

---

## Gold Layer Feature Store

Rather than building a normalized Star Schema (separate Fact and Dimension tables), the Gold layer implements a Denormalized Customer 360 Analytical Base Table (ABT) via `gold.vw_customer_credit_profile`.

| Feature Domain | Key Metrics Engineered | Business Value |
| --- | --- | --- |
| **Demographics & Application** | `customer_age_years`, `total_income`, `credit_amount`, `loan_annuity`, `education_level`, `housing_type` | Establishes baseline borrower capacity and contract structure |
| **External Credit Bureau** | `external_score1–3`, `total_bureau_loans`, `active_bureau_loans`, `total_bureau_debt`, `total_bureau_delinquent_months` | Captures external leverage and third-party repayment history |
| **Revolving & POS Balances** | `average_card_balance`, `max_card_credit_limit`, `max_card_days_past_due`, `average_installments_remaining` | Measures revolving credit utilization and short-term liquidity stress |
| **Payment & App Discipline** | `approved_previous_applications`, `refused_previous_applications`, `total_underpayment_amount`, `maximum_payment_delay_days` | Quantifies historical repayment discipline and delinquency severity |

> **Architecture & Schema Docs:** Explore the `docs/` directory for the Data Architecture diagram, Data Flow Diagram (DFD), Entity-Relationship (ER) diagram, and full 39-column Gold Layer Data Catalogue.

---

## Getting Started

### Prerequisites

* Microsoft SQL Server (2019 or later recommended)
* SQL Server Management Studio (SSMS) or Azure Data Studio
* Raw CSV files from the Home Credit Default Risk dataset

### Execution Order

1. **Initialize Schemas & Bronze Tables:** Run `scripts/bronze/ddl_bronze.sql` and execute `EXEC bronze.load_bronze_layer;`.
2. **Build & Populate Silver Layer:** Run `scripts/silver/ddl_silver.sql` followed by `scripts/silver/proc_load_silver.sql`.
3. **Apply Performance Indexes:** Run `scripts/silver/idx_silver.sql` on the physical Silver tables.
4. **Deploy Gold Flat View:** Run `scripts/gold/view_gold_abt.sql` to create `gold.vw_customer_credit_profile`.

---

## Roadmap

* [x] **Phase 1: Data Warehouse Engineering (Current Repository)** — Bronze ingestion, Silver cleansing/indexing, and Gold Customer 360 ABT view.
* [ ] **Phase 2: Advanced Credit Risk Analytics (Upcoming Separate Project)** — Quantitative portfolio risk analysis (DTI, DSIR, DPD stratification), statistical hypothesis testing, and predictive default modeling built directly on top of `gold.vw_customer_credit_profile`.

---

## Author & License

**Evans Mwandiki**

*B.Sc. Actuarial Science | Aspiring Data Engineer & Credit Risk Analyst*

With an academic foundation in Actuarial Science, I am building practical expertise in SQL development, data engineering, and quantitative risk modeling. This project reflects my hands-on progression in designing automated ETL pipelines, solving complex relational data anomalies, and transforming raw financial records into an analytics-ready data foundation.

* **GitHub:** [@Mwandiki3](https://www.google.com/search?q=https://github.com/Mwandiki3)

This project is licensed under the **MIT License** — feel free to use, modify, and distribute it for educational or portfolio purposes.
