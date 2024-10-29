{% macro create_pk(column_name) %}
    IF NOT EXISTS(
        SELECT *
        FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
        WHERE concat(TABLE_CATALOG, '.', TABLE_SCHEMA, '.', TABLE_NAME) = '{{ this }}'
    )
    BEGIN
        ALTER TABLE {{ this }}
        ADD PRIMARY KEY ({{ column_name }});
    END
{% endmacro %}