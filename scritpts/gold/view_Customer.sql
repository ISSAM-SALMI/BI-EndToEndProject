create view gold.dim_customers as 	
	SELECT 
		  ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
		  ci.cst_id as customer_id,
		  ci.cst_key as customer_number,
		  ci.cst_firstname as first_name,
		  ci.cst_lastname as last_name,
		  la.cntry as country,
		  ci.cst_marital_status as marital_status,
		  CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			   ELSE COALESCE(ca.gen, 'n/a')
		  END AS gender,
		  ca.bdate as birthdate,
		  ci.cst_create_date as create_date
	FROM 
		silver.crm_cust_info ci
	LEFT JOIN 
		silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
	LEFT JOIN	
		silver.erp_loc_a101 la
	ON ci.cst_key = la.cid;


