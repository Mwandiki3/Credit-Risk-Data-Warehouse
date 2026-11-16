# Data Catalogue: `gold.vw_customer_credit_profile`

## 1. Architectural Overview & Metadata

| Property | Specification |
| :--- | :--- |
| **Database Object** | `gold.vw_customer_credit_profile` |
| **Object Type** | Virtual Database View (Denormalized Analytical Base Table / Customer 360 Feature Store) |
| **Data Grain** | One unique row per loan applicant (`customer_id`), totaling **307,511** distinct records |
| **Primary Purpose** | Consolidates core demographics, declared income, external bureau debt, revolving credit card usage, POS/cash loan balances, and historical installment discipline into a single flat feature matrix |
| **Null Handling Policy** | All aggregated historical metrics use `ISNULL(..., 0)` so thin-file borrowers default cleanly to `0` rather than `NULL` |

---

## 2. Column-by-Column Data Dictionary

### A. Customer Identifiers & Core Demographics

| # | Column Name | Source Table & Field | Data Type | Business Definition | Example Values |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **1** | `customer_id` | `hc_application_train.SK_ID_CURR` | `INT` | Unique primary identifier assigned to each loan applicant. | `100002`, `100003`, `456255` |
| **2** | `default_flag` | `hc_application_train.TARGET` | `INT` | Target risk indicator: `1` = client experienced payment difficulties, `0` = loan repaid normally. | `0`, `1` |
| **3** | `contract_type` | `hc_application_train.NAME_CONTRACT_TYPE` | `VARCHAR` | Category of the loan product requested by the applicant. | `'Cash loans'`, `'Revolving loans'` |
| **4** | `customer_gender` | `hc_application_train.CODE_GENDER` | `VARCHAR` | Biological/declared gender of the applicant. | `'M'`, `'F'`, `'XNA'` |
| **5** | `total_income` | `hc_application_train.AMT_INCOME_TOTAL` | `DECIMAL(18,2)` | Total annual/declared income of the applicant. | `202500.00`, `135000.00` |
| **6** | `credit_amount` | `hc_application_train.AMT_CREDIT` | `DECIMAL(18,2)` | Total principal credit amount approved/requested for the current loan. | `406597.50`, `1293502.50` |
| **7** | `loan_annuity` | `hc_application_train.AMT_ANNUITY` | `DECIMAL(18,2)` | Scheduled periodic loan installment payment amount. | `24700.50`, `35698.50` |
| **8** | `goods_price` | `hc_application_train.AMT_GOODS_PRICE` | `DECIMAL(18,2)` | Retail price of the consumer goods financed by the loan (POS/consumer loans). | `351000.00`, `1129500.00` |
| **9** | `income_type` | `hc_application_train.NAME_INCOME_TYPE` | `VARCHAR` | Primary employment or income classification of the borrower. | `'Working'`, `'Commercial associate'`, `'Pensioner'` |
| **10** | `education_level` | `hc_application_train.NAME_EDUCATION_TYPE` | `VARCHAR` | Highest formal academic qualification attained by the applicant. | `'Secondary / secondary special'`, `'Higher education'` |
| **11** | `family_status` | `hc_application_train.NAME_FAMILY_STATUS` | `VARCHAR` | Marital and household status of the client. | `'Single / not married'`, `'Married'`, `'Widow'` |
| **12** | `housing_type` | `hc_application_train.NAME_HOUSING_TYPE` | `VARCHAR` | Current residential living arrangement of the applicant. | `'House / apartment'`, `'Rented apartment'` |
| **13** | `customer_age_years` | `hc_application_train.DAYS_BIRTH` | `DECIMAL(5,2)` | Exact age of the applicant in years at application (`ABS(DAYS_BIRTH / -365.25)`). | `25.90`, `45.89`, `61.05` |
| **14** | `employment_duration_days` | `hc_application_train.DAYS_EMPLOYED` | `INT` | Days employed prior to application (negative = active tenure; `365243` = pensioner code). | `-637`, `-1188`, `365243` |

---

### B. External Credit Bureau Scoring & Summary Metrics

| # | Column Name | Source Table & Field | Data Type | Business Definition | Example Values |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **15** | `external_score1` | `hc_application_train.EXT_SOURCE_1` | `FLOAT` | Normalized risk score from external credit data source 1 (`0` to `1`; higher = lower risk). | `0.083037`, `0.311267`, `NULL` |
| **16** | `external_score2` | `hc_application_train.EXT_SOURCE_2` | `FLOAT` | Normalized risk score from external credit data source 2 (`0` to `1`). | `0.262949`, `0.622246`, `0.713524` |
| **17** | `external_score3` | `hc_application_train.EXT_SOURCE_3` | `FLOAT` | Normalized risk score from external credit data source 3 (`0` to `1`). | `0.139376`, `0.535276`, `NULL` |
| **18** | `total_bureau_loans` | `hc_bureau.SK_ID_BUREAU` | `INT` | Total count of historical and current loans reported to external credit bureaus. | `0`, `4`, `11` |
| **19** | `active_bureau_loans` | `hc_bureau.CREDIT_ACTIVE` | `INT` | Number of currently open/active credit facilities held with external institutions. | `0`, `2`, `5` |
| **20** | `total_bureau_credit_sum` | `hc_bureau.AMT_CREDIT_SUM` | `DECIMAL(18,2)` | Cumulative credit limit/principal granted across all external bureau records. | `0.00`, `865055.56`, `3825000.00` |
| **21** | `total_bureau_debt` | `hc_bureau.AMT_CREDIT_SUM_DEBT` | `DECIMAL(18,2)` | Total current outstanding debt owed across all external credit bureau accounts. | `0.00`, `245781.00`, `1120000.00` |
| **22** | `max_bureau_days_overdue` | `hc_bureau.CREDIT_DAY_OVERDUE` | `INT` | Maximum days past due recorded on any external credit bureau account at application. | `0`, `15`, `142` |
| **23** | `total_bureau_balance_records` | `hc_bureau_balance.MONTHS_BALANCE` | `INT` | Total count of monthly historical status snapshots across all external bureau loans. | `0`, `48`, `196` |
| **24** | `total_bureau_delinquent_months` | `hc_bureau_balance.STATUS` | `INT` | Total historical months flagged as delinquent (`1–30`, `31–60`, `61–90`, `91–120`, or `120+ DPD`). | `0`, `2`, `14` |

---

### C. Internal Revolving Credit Card & POS/Cash Histories

| # | Column Name | Source Table & Field | Data Type | Business Definition | Example Values |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **25** | `total_credit_card_records` | `hc_credit_card_balance.SK_ID_PREV` | `INT` | Total number of monthly historical credit card balance snapshots with Home Credit. | `0`, `24`, `96` |
| **26** | `average_card_balance` | `hc_credit_card_balance.AMT_BALANCE` | `DECIMAL(18,2)` | Mean monthly revolving balance carried across the customer's Home Credit cards. | `0.00`, `45230.15`, `189400.00` |
| **27** | `max_card_credit_limit` | `hc_credit_card_balance.AMT_CREDIT_LIMIT_ACTUAL` | `DECIMAL(18,2)` | Highest credit card limit extended to the customer during their historical card tenure. | `0.00`, `90000.00`, `450000.00` |
| **28** | `max_card_days_past_due` | `hc_credit_card_balance.SK_DPD` | `INT` | Worst historical delinquency (maximum days past due) on any Home Credit card account. | `0`, `7`, `65` |
| **29** | `total_pos_cash_records` | `hc_posh_cash_balance.SK_ID_PREV` | `INT` | Total count of monthly balance snapshots across prior Point-of-Sale (POS) and cash loans. | `0`, `18`, `72` |
| **30** | `average_installments_remaining` | `hc_posh_cash_balance.CNT_INSTALMENT_FUTURE` | `DECIMAL(10,2)` | Average number of future installments remaining across historical POS/cash snapshots. | `0.00`, `6.50`, `14.25` |
| **31** | `max_pos_cash_days_past_due` | `hc_posh_cash_balance.SK_DPD` | `INT` | Worst historical delinquency (maximum days past due) recorded across prior POS/cash loans. | `0`, `12`, `94` |

---

### D. Prior Application Outcomes, Payment Discipline & Audit Metadata

| # | Column Name | Source Table & Field | Data Type | Business Definition | Example Values |
| :---: | :--- | :--- | :---: | :--- | :--- |
| **32** | `total_previous_applications` | `hc_previous_application.SK_ID_PREV` | `INT` | Total count of prior loan applications submitted by the client to Home Credit. | `0`, `1`, `6` |
| **33** | `approved_previous_applications` | `hc_previous_application.NAME_CONTRACT_STATUS` | `INT` | Count of previous Home Credit loan applications that were approved. | `0`, `1`, `4` |
| **34** | `refused_previous_applications` | `hc_previous_application.NAME_CONTRACT_STATUS` | `INT` | Count of previous Home Credit loan applications that were rejected/refused. | `0`, `1`, `3` |
| **35** | `average_previous_credit_amount` | `hc_previous_application.AMT_CREDIT` | `DECIMAL(18,2)` | Average credit amount approved/requested across all prior Home Credit applications. | `0.00`, `179055.00`, `675000.00` |
| **36** | `total_installments_paid` | `hc_instalments_payments.SK_ID_PREV` | `INT` | Total count of individual historical loan installment payments recorded for the customer. | `0`, `19`, `145` |
| **37** | `total_underpayment_amount` | `hc_instalments_payments.AMT_INSTALMENT - AMT_PAYMENT` | `DECIMAL(18,2)` | Cumulative variance between scheduled and actual payments (positive = net underpayment). | `0.00`, `4500.00`, `-1250.50` |
| **38** | `maximum_payment_delay_days` | `hc_instalments_payments.DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT` | `INT` | Maximum days paid late after the scheduled due date (`0` or negative = on-time/early). | `0`, `4`, `38` |
| **39** | `gold_view_refresh_date` | System Function (`GETDATE()`) | `DATETIME` | Execution timestamp recording when the Gold layer view was queried or materialized. | `'2026-11-16 19:09:42.110'` |
