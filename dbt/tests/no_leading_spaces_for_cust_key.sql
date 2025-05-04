SELECT
    cst_key
FROM {{ ref('crm_cust_info') }}
--WHERE cst_key != TRIM(cst_key);