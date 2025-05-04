{% test check_for_date_validity(model, column_name) %}
    SELECT *
    FROM {{ model }}
    WHERE {{ column_name }} IS NOT NULL
      AND {{ column_name }} > CURRENT_DATE
{% endtest %}