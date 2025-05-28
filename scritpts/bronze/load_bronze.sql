/*
   This stored procedure loads raw data from local CSV files into Bronze layer tables.
   For each table, it:
     - Prints start message
     - Truncates existing data
     - Loads new data using BULK INSERT
     - Calculates and prints load duration in seconds
   If any error happens, it shows the error message.
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE 
        @start DATETIME,
        @end DATETIME,
        @duration NVARCHAR(100),
        @batch_start DATETIME,
        @batch_end DATETIME,
        @batch_duration NVARCHAR(100)

    BEGIN TRY
        SET @batch_start = GETDATE();
        PRINT '==========================================================='
        PRINT '>>> [START] Bronze Layer Data Load'
        PRINT '>>> Start Time: ' + CAST(@batch_start AS NVARCHAR)
        PRINT '==========================================================='

        -- ===================== CRM Data Load =====================
        PRINT '>>> [SECTION] Loading CRM Tables...'

        -- crm_cust_info
        PRINT '--- [TABLE] crm_cust_info'
        SET @start = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info;
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\DWHP\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end = GETDATE();
        SET @duration = CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds';
        PRINT '>>> [DONE] crm_cust_info loaded in ' + @duration;

        -- crm_sales_details
        PRINT '--- [TABLE] crm_sales_details'
        SET @start = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\DWHP\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end = GETDATE();
        SET @duration = CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds';
        PRINT '>>> [DONE] crm_sales_details loaded in ' + @duration;

        -- crm_prd_info
        PRINT '--- [TABLE] crm_prd_info'
        SET @start = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\DWHP\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end = GETDATE();
        SET @duration = CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds';
        PRINT '>>> [DONE] crm_prd_info loaded in ' + @duration;

        -- ===================== ERP Data Load =====================
        PRINT '>>> [SECTION] Loading ERP Tables...'

        -- erp_cust_az12
        PRINT '--- [TABLE] erp_cust_az12'
        SET @start = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\DWHP\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end = GETDATE();
        SET @duration = CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds';
        PRINT '>>> [DONE] erp_cust_az12 loaded in ' + @duration;

        -- erp_loc_a101
        PRINT '--- [TABLE] erp_loc_a101'
        SET @start = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\DWHP\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end = GETDATE();
        SET @duration = CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds';
        PRINT '>>> [DONE] erp_loc_a101 loaded in ' + @duration;

        -- erp_px_cat_g1v2
        PRINT '--- [TABLE] erp_px_cat_g1v2'
        SET @start = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\DWHP\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );
        SET @end = GETDATE();
        SET @duration = CAST(DATEDIFF(SECOND, @start, @end) AS NVARCHAR) + ' seconds';
        PRINT '>>> [DONE] erp_px_cat_g1v2 loaded in ' + @duration;

        -- ===================== Completion =====================
        SET @batch_end = GETDATE();
        SET @batch_duration = CAST(DATEDIFF(SECOND, @batch_start, @batch_end) AS NVARCHAR) + ' seconds';

        PRINT '==========================================================='
        PRINT '>>> [END] Bronze Layer Data Load Completed Successfully'
        PRINT '>>> End Time: ' + CAST(@batch_end AS NVARCHAR)
        PRINT '>>> Total Duration: ' + @batch_duration
        PRINT '==========================================================='

    END TRY

    BEGIN CATCH
        PRINT '==========================================================='
        PRINT '!!! ERROR while loading data into Bronze Layer'
        PRINT '>>> ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT '==========================================================='
    END CATCH
END;
