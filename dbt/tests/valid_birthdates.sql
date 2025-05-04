SELECT *
FROM {{ model }}
WHERE birth_date IS NOT NULL
  AND birth_date > CURRENT_DATE
