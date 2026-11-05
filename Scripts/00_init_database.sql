--------------------------------------------------------------------------------
-- SCRIPT NAME: 00_init_database.sql
-- PURPOSE    : Initializes the Credit Risk Data Warehouse environment from 
--              scratch. It safely drops any existing instance of the database 
--              and recreates it along with the three Medallion Architecture 
--              schemas (bronze, silver, and gold).
-- 
-- ⚠️ WARNING : DESTRUCTIVE OPERATION. This script contains a DROP DATABASE 
--              command enforced with SINGLE_USER WITH ROLLBACK IMMEDIATE. 
--              Running this script will forcefully terminate all active 
--              connections and completely erase any existing data in the 
--              'CreditRiskDatawarehouse' database. Use with caution.
----------------------------------------------------------------------------------
--Create database
USE MASTER;
GO
--Drop and recreate the datawarehouse
IF EXISTS (SELECT 1 FROM sys.databases WHERE name='CreditRiskDatawarehouse')
BEGIN
	ALTER DATABASE CreditRiskDatawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE CreditRiskDatawarehouse;
END;
GO
--Create CreditRiskDatawarehouse database
CREATE DATABASE CreditRiskDatawarehouse;
GO
USE CreditRiskDatawarehouse;
GO
--create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
