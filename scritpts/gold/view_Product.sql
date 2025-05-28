create view gold.dim_product as
SELECT 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id as product_id,    
	pn.prd_key as product_number,
    pn.prd_nm as product_name,
	pn.cat_id as category_id,
	PC.CAT as category,
	PC.SUBCAT as subcategory,
	PC.MAINTENANCE,
    pn.prd_cost as cost,
    pn.prd_line as product_line,
    pn.prd_start_dt as start_date
FROM 
	silver.crm_prd_info  pn
LEFT JOIN
	silver.erp_px_cat_g1v2 pc
ON PN.cat_id = PC.ID
WHERE
	pn.prd_end_dt is null

