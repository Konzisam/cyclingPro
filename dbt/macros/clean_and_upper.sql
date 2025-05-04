{% macro clean_and_upper(field) %}
    CASE
        WHEN {{ field }} IS NULL THEN NULL
        ELSE UPPER(TRIM({{ field }}))
    END
{% endmacro %}
