CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @StartTime DATETIME2, @EndTime DATETIME2, @DurationMs INT;
    DECLARE @start_time DATETIME2 = SYSUTCDATETIME();
    DECLARE @end_time DATETIME2;
    DECLARE @duration_ms INT;
    -- crm_cust_info
    PRINT '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;

PRINT '>> Inserting Data into: silver.crm_cust_info';

-- Start timer
SET @StartTime = SYSDATETIME();

-- Insert cleaned and transformed data
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
        ELSE 'n/a'
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) AS sub
WHERE flag_last = 1;

-- End timer and display duration
SET @EndTime = SYSDATETIME();
SET @DurationMs = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
PRINT '   Insert completed in ' + CAST(@DurationMs AS NVARCHAR(20)) + ' ms';


    -- crm_sales_details
    PRINT '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;

    PRINT '>> Inserting Data into: silver.crm_sales_details';
    SET @StartTime = SYSDATETIME();
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT	
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
             ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
        END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
             THEN sls_quantity * ABS(sls_price)
             ELSE sls_sales
        END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price <= 0
             THEN ABS(sls_sales) / NULLIF(sls_quantity, 0)
             ELSE sls_price
        END AS sls_price
    FROM bronze.crm_sales_details;
    SET @EndTime = SYSDATETIME();
    SET @DurationMs = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT '   Insert completed in ' + CAST(@DurationMs AS NVARCHAR) + ' ms';

    -- erp_px_cat_g1v2
    PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    PRINT '>> Inserting Data into: silver.erp_px_cat_g1v2';
    SET @StartTime = SYSDATETIME();
    INSERT INTO silver.erp_px_cat_g1v2 (
        id, 
        cat,
        subcat,
        MAINTENANCE
    )
    SELECT 
        id, 
        cat,
        subcat,
        MAINTENANCE
    FROM bronze.erp_px_cat_g1v2;
    SET @EndTime = SYSDATETIME();
    SET @DurationMs = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT '   Insert completed in ' + CAST(@DurationMs AS NVARCHAR) + ' ms';

    -- erp_loc_a101
    PRINT '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;

    PRINT '>> Inserting Data into: silver.erp_loc_a101';
    SET @StartTime = SYSDATETIME();
    INSERT INTO silver.erp_loc_a101 (
        CID,
        CNTRY
    )
    SELECT 
        REPLACE(UPPER(CID), '-', '') AS CID,
        CASE 
            WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
            WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
            ELSE CNTRY
        END AS CNTRY
    FROM bronze.erp_loc_a101;
    SET @EndTime = SYSDATETIME();
    SET @DurationMs = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT '   Insert completed in ' + CAST(@DurationMs AS NVARCHAR) + ' ms';

    -- erp_cust_az12
    PRINT '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;

    PRINT '>> Inserting Data into: silver.erp_cust_az12';
    SET @StartTime = SYSDATETIME();
    INSERT INTO silver.erp_cust_az12 (
        CID,
        BDATE,
        GEN
    )
    SELECT 
        CASE 
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
            ELSE cid
        END AS cid,
        CASE 
            WHEN bdate > GETDATE() THEN NULL
            ELSE bdate
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen
    FROM bronze.erp_cust_az12;
    SET @EndTime = SYSDATETIME();
    SET @DurationMs = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    PRINT '   Insert completed in ' + CAST(@DurationMs AS NVARCHAR) + ' ms';

    SET @end_time = SYSUTCDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Finished silver.load_silver procedure';
    PRINT '>> Total Duration (ms): ' + CAST(@duration_ms AS VARCHAR(10));

END;