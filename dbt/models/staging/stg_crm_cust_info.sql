{{ config(materialized='table') }}

SELECT
		cst_id AS customer_id,
		cst_key As customer_key,
		-- equivalen tto TRIM(value)
        {{ clean_and_upper('cst_firstname') }} AS cst_firstname,
        {{ clean_and_upper('cst_lastname') }} AS cst_lastname,
        -- equivalent to UPPER(TRIM(value)
       {{ normalize_value(
            'cst_marital_status',
            {'S': 'Single', 'M': 'Married'},
            'n/a'
        ) }} AS cst_marital_status,
        {{ normalize_value(
            'cst_gndr',
            {'F': 'Female', 'M': 'Male'},
            'n/a'
        ) }} AS cst_gender,
			cst_create_date
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM {{ source('raw_data', 'crm_cust_info') }}
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1