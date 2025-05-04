{{ config(materialized='table') }}

SELECT
    -- Remove 'NAS' prefix if present in the customer ID
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
        ELSE cid
    END AS customer_id,

    -- Set future birthdates to NULL
    {{ safe_date_cast('bdate') }} AS birth_date,

    -- Normalize gender values: 'M', 'MALE' -> 'Male', 'F', 'FEMALE' -> 'Female'
    {{ normalize_value(
        'gen',
        {'F': 'Female', 'FEMALE': 'Female', 'M': 'Male', 'MALE': 'Male'},
        'n/a'
    ) }} AS gender

FROM {{ source('raw_data', 'erp_cust_az12') }}
