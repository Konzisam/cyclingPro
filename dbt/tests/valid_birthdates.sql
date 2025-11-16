SELECT *
FROM {{ ref('dim_customers') }}
WHERE birth_date IS NOT NULL
  AND birth_date > CURRENT_DATE
