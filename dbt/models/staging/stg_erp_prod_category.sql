{{ config(materialized='table') }}

SELECT
    id,
    {{ clean_and_upper('cat') }} AS category,
    {{ clean_and_upper('subcat') }} AS subcategory,
    {{ clean_and_upper('maintenance') }} AS maintenance
FROM {{ source('raw_data', 'erp_px_cat_g1v2') }}
WHERE id IS NOT NULL
