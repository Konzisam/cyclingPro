{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY crm_pi.prd_start_date, crm_pi.prd_key) AS product_key,  -- Surrogate key
    crm_pi.prd_id AS product_id,
    crm_pi.prd_key AS product_number,
    crm_pi.prd_number AS product_name,
    crm_pi.category_id,
    erp_pi.category,
    erp_pi.subcategory,
    erp_pi.maintenance AS maintenance,
    crm_pi.prd_cost AS cost,
    crm_pi.prd_line AS product_line,
    crm_pi.prd_start_date AS start_date
FROM {{ ref('stg_crm_prd_info') }} crm_pi
LEFT JOIN {{ ref('stg_erp_prod_category') }} erp_pi
    ON crm_pi.category_id = erp_pi.id
WHERE crm_pi.prd_end_date IS NULL  -- Filter out all historical data
