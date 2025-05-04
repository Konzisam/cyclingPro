{{ config(materialized='table') }}

SELECT
    -- Remove dashes from 'cid' and make it uppercase
    {{ clean_and_upper("REPLACE(cid, '-', '')") }} AS customer_id,

    -- Normalize country codes to full country names
    {{ normalize_value(
        'cntry',
        {'DE': 'Germany', 'US': 'United States', 'USA': 'United States'},
        'n/a'
    ) }} AS country

FROM {{ source('raw_data', 'erp_loc_a101') }}
