{{ config(materialized='table') }}

SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS category_id, -- Extract category ID
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,        -- Extract product key
    {{ clean_and_upper('prd_nm') }} AS prd_number,
    COALESCE(prd_cost, 0) AS prd_cost,
    {{ normalize_value(
        'prd_line',
        {'M': 'Mountain', 'R': 'Road', 'S': 'Other Sales', 'T': 'Touring'},
        'n/a'
    ) }} AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_date,
    CAST(
        CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) - INTERVAL '1 day'
        AS DATE
    ) AS prd_end_date

FROM {{ source('raw_data', 'crm_prd_info') }}
