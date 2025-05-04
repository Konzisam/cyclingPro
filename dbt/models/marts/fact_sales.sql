{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY crm_sl.sls_order_dt, crm_sl.sls_ord_num) AS order_key,  -- Surrogate key
    crm_sl.sls_ord_num AS order_number,
    prd.product_key AS product_key,
    cst.customer_key AS customer_key,
    crm_sl.sls_order_dt AS order_date,
    crm_sl.sls_ship_dt AS shipping_date,
    crm_sl.sls_due_dt AS due_date,
    crm_sl.sls_sales AS sales_amount,
    crm_sl.sls_quantity AS quantity,
    crm_sl.sls_price AS price
FROM {{ ref('stg_crm_sales_details') }} crm_sl
LEFT JOIN {{ ref('dim_products') }} prd
    ON crm_sl.sls_prd_key = prd.product_number
LEFT JOIN {{ ref('dim_customers') }} cst
    ON crm_sl.sls_cust_id = cst.customer_id
