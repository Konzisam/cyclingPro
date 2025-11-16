{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY crm_ci.customer_id) AS customer_key, -- Surrogate key
    crm_ci.customer_id,
    crm_ci.customer_key AS customer_number,
    crm_ci.cst_firstname AS first_name,
    crm_ci.cst_lastname AS last_name,
    erp_lo.country AS country,
    crm_ci.cst_marital_status AS marital_status,
    CASE
        WHEN crm_ci.cst_gender != 'n/a' THEN crm_ci.cst_gender
        ELSE COALESCE(erp_ci.gender, 'n/a')
    END AS gender,
    erp_ci.birth_date,
    crm_ci.cst_create_date AS create_date
FROM {{ ref('stg_crm_cust_info') }} crm_ci
LEFT JOIN {{ ref('stg_erp_cust_info') }} erp_ci
    ON crm_ci.customer_key = erp_ci.customer_id
LEFT JOIN {{ ref('stg_erp_location') }} erp_lo
    ON crm_ci.customer_key = erp_lo.customer_id
