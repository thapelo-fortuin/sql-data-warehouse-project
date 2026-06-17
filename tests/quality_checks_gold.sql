SELECT DISTINCT 
ci.cst_gndr,
ca.gen,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr ---CRM is the Master for Gender info
	ELSE COALESCE(ca.gen,'n/a')
END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key =ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

SELECT * FROM gold.dim_customers

--Foreign Key Integrity (Dimensions)
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
