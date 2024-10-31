{% macro create_pk(column_name) %}
    IF NOT EXISTS(
        SELECT *
        FROM SYS.KEY_CONSTRAINTS
        WHERE [TYPE] = 'PK' AND [PARENT_OBJECT_ID] = OBJECT_ID('{{ this.schema }}.{{ this.name }}')
    )
    BEGIN
        ALTER TABLE {{ this }}
        ADD PRIMARY KEY ({{ column_name }});
    END
{% endmacro %}