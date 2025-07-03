CREATE VIEW gold.dim_customer AS
SELECT
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
	ci.cst_id AS Customer_id ,
	ci.cst_key AS Customer_Number ,
	ci.cst_firstname AS First_name,
	ci.cst_lastname AS last_name,
	ci.cst_marital_status AS marital_status,
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM IS THE MASTER FOR GENDER INFO 
    ELSE COALESCE (ca.gen,'n/a')
    END AS new_gen,
	ci.cst_create_date AS create_date,
	ca.bdate AS Birthdate,
	la.cntry AS Country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loca_101 la
	ON ci.cst_key = la.cid;
    
SELECT DISTINCT new_gen FROM gold.dim_customer;

SELECT DISTINCT
	
	ci.cst_gndr,
	ca.gen,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr -- CRM IS THE MASTER FOR GENDER INFO 
    ELSE COALESCE (ca.gen,'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loca_101 la
	ON ci.cst_key = la.cid;
    
    DROP VIEW Gold.dim_products;
CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt , pn.prd_key) AS product_key,
    pn.prd_id AS Product_id ,
    pn.prd_key AS product_number ,
	pn.prd_nm AS Product_name,
	pn.cat_id AS Category_id,
	pc.cat AS Category ,
	pc.subcat AS Subcategory  ,
	pc.Maintenance ,
    pn.prd_cost AS Cost,
    pn.prd_line as product_line,
    pn.prd_start_dt AS Start_date

    FROM silver.crm_prd_info pn 
    LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id =pc.id ;
   
    
    SELECT* FROM Gold.dim_products;
    SELECT *
FROM gold.dim_products
WHERE product_number IS NULL;
SELECT *
FROM gold.dim_products
WHERE product_number = 'BK-R93R-62';


CREATE VIEW gold.facts_sales AS
SELECT 
sd.sls_ord_num AS order_number ,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS Shipping_date,
sd.sls_due_dt AS Due_date,
sd.sls_sales AS sales_amount, 
sd.sls_quantity AS quantity,
sd.sls_price
FROM silver.crm_sales_details sd 
LEFT JOIN gold.dim_products pr 
ON sd.sls_prd_key=pr.product_number
LEFT JOIN gold.dim_customer cu
ON sd.sls_cust_id= cu.customer_id;

SELECT DISTINCT sd.sls_prd_key
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
  ON sd.sls_prd_key = pr.product_number
WHERE pr.product_number IS NULL;

SELECT 
* FROM gold.facts_sales f
LEFT JOIN gold.dim_customer c
ON c.customer_key=f.customer_key 
LEFT JOIN gold.dim_products p
ON p.product_key=f.product_key
WHERE p.product_key IS NULL;
