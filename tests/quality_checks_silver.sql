/*
=====================================================================================
Quality Checks
===================================================================================
Script Purpose:
  This script performs various quality checks for data inconsistency, accuracy,
  and standardizatiom acrosss the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    -Unwanted spaces in string fileds.
    -Data standardization and consistency.
    -Invalid date ranges and orders.
    -Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading silver layer
    - Investigate and resole any discrepancies found during the checks
=========================================================================================

*/

--Check For Nulls or Duplicates in Primary Key
--Expectation: No result

USE DataWarehouse
SELECT 
cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


--Quality Check For unwanted spaces in string values
--TRIM(), removes leanding and trailing spaces from a string
--Expectation: No results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr) -- if the original value is not equal to the same value after trimming it means there are spaces

--Data Standardization & Consistency
-- in our data warehouse, we aim to store clear and meaningful values rather than using abbreviated terms
-- instead of M or F =  Male/Female
-- In our data warehouse we use the default value 'n/a' for missing values

SELECT *
FROM silver.crm_cust_info


--- Data cleaning in prd_info table
--SUBSTRING(), Extracts a specific part of a string value




--check for NULLS or Negative Numbers
--Expectation: No results

SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

--Data standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info


--Check for Invalid Data Orders
--End data must be earlier than start date
--#1 Solution = Switch End Date and Start Date
	--issue data is overlapping
	-- Each record must have a Start Date!!
-- #2 Solution : Derive the End Date from the Start Date
	--End Date = Start Date of the 'NEXT' Record

--NULLIF() : Returns NULL if two given values are equal; otherwise, it return the first expression
SELECT 
NULLIF(sls_order_dt,0) sls_oder_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <=0 
OR LEN(sls_order_dt) != 8
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101

--Check fo Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--Check Data consistency: Between Sales, Quantity, and Price
---Business Rules---
--Total Sales =Quantity * Price
--Negative, zeros, Nulls are NOT ALLOWED

--#1 Solution: Data issues will be fixed direct in source system
---#2 Solution: Data issues has to be fixed in data warehouse

--Rules:
		--IF sales is negative, zero, or null, derive it using Quantity and Price.
		--If Price is zero or null, calculate it using Sales and Quantity
		--If Price is negative, convert it to a positive value
SELECT DISTINCT
sls_sales
sls_quantity,
sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <=0 OR sls_quantity <=0 OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details


---Identify Out-of-Range Dates
--Check for very old customers
--Check for birthdays in the future
SELECT DISTINCT 
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--Data Standardization & Consistency


--Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat)
--Check For Nulls or Duplicates in Primary Key
--Expectation: No result

USE DataWarehouse
SELECT 
cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


--Quality Check For unwanted spaces in string values
--TRIM(), removes leanding and trailing spaces from a string
--Expectation: No results
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr) -- if the original value is not equal to the same value after trimming it means there are spaces

--Data Standardization & Consistency
-- in our data warehouse, we aim to store clear and meaningful values rather than using abbreviated terms
-- instead of M or F =  Male/Female
-- In our data warehouse we use the default value 'n/a' for missing values

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info


-- Check For NUlls or Duplicates in Primary Key
--Expectation: no result

SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
