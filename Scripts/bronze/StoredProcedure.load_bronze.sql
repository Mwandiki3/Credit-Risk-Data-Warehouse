--Encapsulates the entire Bronze layer ingestion pipeline into a single automated database procedure.
--Implements built-in error handling to safely catch, log, and display details if any table load fails.
--Tracks performance by capturing start and end timestamps for every individual table load.
--Calculates and prints the exact duration in seconds for each table and the entire batch execution.
--Clears out old data using truncate commands before streaming fresh raw CSV data into each staging table.
--Executes high-performance bulk insertions with table locking to mirror the raw source files accurately.
--How to use in SQL server
--EXEC bronze.load_bronze_layer;
CREATE OR ALTER PROCEDURE bronze.load_bronze_layer AS
BEGIN
BEGIN TRY
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME ;
SET @batch_start_time=GETDATE();
PRINT'===============================================================';
PRINT'Loading Bronze layer';
PRINT'=====================================================================';
    
    SET @start_time=GETDATE();
    PRINT'>> Truncating:application_train_table';
    TRUNCATE TABLE bronze.hc_application_train;
    PRINT'>>Inserting Data into hc_application_train';  
    BULK INSERT bronze.hc_application_train
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_application_train.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,         
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',              
        TABLOCK             
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_application_train successfully.';
    --------------------------------------------------------------------------------
    -- 2. BULK INSERT: bureau
    --------------------------------------------------------------------------------
    PRINT'=====================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc bureau table';
    TRUNCATE TABLE bronze.hc_bureau;
    PRINT'>>Inserting Data into hc bureau table'; 
    BULK INSERT bronze.hc_bureau
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_bureau.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_bureau successfully.';
    --------------------------------------------------------------------------------
    -- 3. BULK INSERT: bureau_balance
    --------------------------------------------------------------------------------
    PRINT'>>==================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc bureau balance table';
    TRUNCATE TABLE bronze.hc_bureau_balance;
    PRINT'>>Inserting Data into hc bureau balance table'; 
    BULK INSERT bronze.hc_bureau_balance
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_bureau_balance.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_bureau_balance successfully.';
    --------------------------------------------------------------------------------
    -- 4. BULK INSERT: credit_card_balance
    --------------------------------------------------------------------------------
    PRINT'>>===================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc credit card balance table';
    TRUNCATE TABLE bronze.hc_credit_card_balance;
    PRINT'>>Inserting Data into hc credit card balance table';
    BULK INSERT bronze.hc_credit_card_balance
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_credit_card_balance.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_credit_card_balance successfully.';
    --------------------------------------------------------------------------------
    -- 5. BULK INSERT: instalments_payments
    --------------------------------------------------------------------------------
    PRINT'>>=======================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc instalments payment table';
    TRUNCATE TABLE bronze.hc_instalments_payments;
    PRINT'>>Inserting Data into hc instalment payment table';
    BULK INSERT bronze.hc_instalments_payments
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_installments_payments.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_instalments_payments successfully.';
    --------------------------------------------------------------------------------
    -- 6. BULK INSERT: posh_cash_balance
    --------------------------------------------------------------------------------
    PRINT'>>========================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc posh balance table';
    TRUNCATE TABLE bronze.hc_posh_cash_balance;
    PRINT'>>Inserting Data into hc posh balance table';
    BULK INSERT bronze.hc_posh_cash_balance
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_POS_CASH_balance.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_posh_cash_balance successfully.';
    --------------------------------------------------------------------------------
    -- 7. BULK INSERT: previous_application
    --------------------------------------------------------------------------------
    PRINT'>>=======================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc previous application table';
    TRUNCATE TABLE bronze.hc_previous_application;
    PRINT'>>Inserting Data into previous application table';
    BULK INSERT bronze.hc_previous_application
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_previous_application.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_previous_application successfully.';
    --------------------------------------------------------------------------------
    -- 8. BULK INSERT: sample_submission
    --------------------------------------------------------------------------------
    PRINT'>>==========================================================================';
    SET @start_time=GETDATE();
    PRINT'>>Truncating hc sample submission table';
    TRUNCATE TABLE bronze.hc_sample_submission;
    PRINT'>>Inserting Data into sample submission table';
    BULK INSERT bronze.hc_sample_submission
    FROM 'C:\Users\EVANS\Desktop\SQL DATA SOURCES\HC_sample_submission.csv'
    WITH (
        FORMAT = 'CSV',
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '0x0a',
        TABLOCK
    );
    SET @end_time =GETDATE();
    PRINT'>>Load Duration' +CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
    PRINT 'Loaded bronze.hc_sample_submission successfully!';
    END TRY
BEGIN CATCH
        PRINT'=============================================';
        PRINT'ERROR OCCURED DURING LOADING';
        PRINT'Error Message'+ ERROR_MESSAGE();
        PRINT'Error Number'+ CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT'Error Line'+CAST(ERROR_LINE() AS NVARCHAR);
        PRINT('Error Procedure'+ERROR_PROCEDURE());
END CATCH
END
SET @batch_end_time =GETDATE();
    PRINT'>>Batch Load Duration' +CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR)+ 'seconds';
   

