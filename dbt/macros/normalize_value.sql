{% macro normalize_value(field, mapping_dict, default_value) %}
    CASE
        {% for key, value in mapping_dict.items() %}
            WHEN {{ clean_and_upper(field) }} = '{{ key|upper }}' THEN '{{ value }}'
        {% endfor %}
        ELSE '{{ default_value }}'
    END
{% endmacro %}
