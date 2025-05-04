{{ config(materialized='table') }}

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    {{ safe_date_cast('sls_order_dt') }} AS sls_order_dt,
    {{ safe_date_cast('sls_ship_dt') }} AS sls_ship_dt,
    {{ safe_date_cast('sls_due_dt') }} AS sls_due_dt,

    -- Recalculate sales if it's null, <= 0, or inconsistent
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    -- Derive price if it's null or <= 0
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

FROM {{ source('raw_data', 'crm_sales_details') }}
