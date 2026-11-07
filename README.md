# Credit-Risk-Data-Warehouse
Welcome to the Credit Risk Data Warehouse Project! Whether you are a data scientist building predictive risk models, a data analyst exploring default trends, or a business stakeholder reviewing credit exposure, this repository provides a clean, robust, and scalable data infrastructure designed to turn raw financial data into actionable insights.

🚀 Project Overview
The Credit Risk Data Warehouse Project is an end-to-end data engineering solution built on Microsoft SQL Server. It follows industry-standard Medallion Architecture (Bronze, Silver, Gold layers) and Star Schema dimensional modeling principles to process, clean, and structure the complex Home Credit Default Risk dataset.

🏛️ Medallion Architecture Breakdown
This data warehouse is engineered using a multi-layer Medallion architecture to ensure data traceability, cleanliness, and high analytical performance:

1. Bronze Layer (Raw Staging)
What it does: Acts as a 100% un-transformed, literal raw mirror of the source CSV files.

Key Practices: Every single column across all staging tables is uniformly typed as VARCHAR(255) to completely prevent type-conversion errors during initial ingestion and preserve missing values as NULLs.

Automation: Loaded using optimized bulk insert scripts and orchestrated via automated T-SQL stored procedures (bronze.load_bronze_layer) with built-in error handling (TRY...CATCH) and execution duration tracking.

2. Silver Layer (Cleansing & Integration)
What it does: Transforms raw staging data into a clean, structured, and trustworthy operational format.

Key Practices: Casts data fields into their correct native SQL data types (e.g., integers, decimals, dates), strips out duplicate records, standardizes text formatting, and handles missing or corrupted values intelligently. It establishes structural consistency across related datasets (such as application logs, bureau records, and installment histories).

3. Gold Layer (Dimensional Modeling & Analytics)
What it does: Delivers business-ready, highly aggregated data optimized for reporting, visualization, and predictive machine learning models.

Key Practices: Implements a rigorous Star Schema architecture featuring optimized Fact Tables (capturing quantitative metrics like loan amounts, payment defaults, and credit limits) and Dimension Tables (descriptive attributes of clients, contracts, and geographic data). This layer provides lightning-fast query performance for data scientists, analysts, and business stakeholders.
📜 License
This project is open-source and available under the MIT License. You are free to use, modify, and build upon this project for educational and professional purposes.

👨‍💻 About the Author
Evans Mwandiki (GitHub: Mwandiki3) is a data practitioner and quantitative enthusiast passionate about database architecture, data warehousing, and building scalable data pipelines. With a strong background in analytical problem-solving, Evans focuses on designing efficient SQL-driven data workflows that bridge raw data systems with practical business intelligence and risk modeling.
