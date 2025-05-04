{% macro safe_date_cast(field_name) %}
    {% if target.type == 'snowflake' %}
        CASE
            WHEN CAST({{ field_name }} AS STRING) = '0' THEN NULL
            WHEN LENGTH(CAST({{ field_name }} AS STRING)) != 8
                 AND {{ field_name }} NOT LIKE '%-%'
                 THEN NULL
            WHEN {{ field_name }} LIKE '%-%' THEN
                CASE
                    WHEN TO_DATE(CAST({{ field_name }} AS STRING), 'YYYY-MM-DD') > CURRENT_DATE THEN NULL
                    ELSE TO_DATE(CAST({{ field_name }} AS STRING), 'YYYY-MM-DD')
                END
            ELSE
                CASE
                    WHEN TO_DATE(CAST({{ field_name }} AS STRING), 'YYYYMMDD') > CURRENT_DATE THEN NULL
                    ELSE TO_DATE(CAST({{ field_name }} AS STRING), 'YYYYMMDD')
                END
        END

    {% elif target.type == 'duckdb' %}
        CASE
            WHEN CAST({{ field_name }} AS STRING) = '0' THEN NULL
            WHEN LENGTH(CAST({{ field_name }} AS STRING)) != 8
                 AND CAST({{ field_name }} AS STRING) NOT LIKE '%-%'
                 THEN NULL
            WHEN CAST({{ field_name }} AS STRING) LIKE '%-%' THEN
                CASE
                    WHEN STRPTIME(CAST({{ field_name }} AS STRING), '%Y-%m-%d') > CURRENT_DATE THEN NULL
                    ELSE STRPTIME(CAST({{ field_name }} AS STRING), '%Y-%m-%d')
                END
            ELSE
                CASE
                    WHEN STRPTIME(CAST({{ field_name }} AS STRING), '%Y%m%d') > CURRENT_DATE THEN NULL
                    ELSE STRPTIME(CAST({{ field_name }} AS STRING), '%Y%m%d')
                END
        END
    {% else %}
        NULL
    {% endif %}
{% endmacro %}
