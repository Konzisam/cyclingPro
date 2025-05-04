-- macros/no_leading_trailing_spaces_for_cst_key.sql
{% test no_leading_trailing_spaces_for_cst_key(model, column_name) %}
WITH check_spaces AS (
    SELECT {{ column_name }}
    FROM {{ model }}
    WHERE {{ column_name }} != TRIM({{ column_name }})
)
SELECT COUNT(*)
FROM check_spaces
HAVING COUNT(*) > 0
{% endtest %}
