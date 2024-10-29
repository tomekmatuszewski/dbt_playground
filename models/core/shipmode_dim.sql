{{
    config(
        materialized='table',
        on_schema_change='append_new_columns',
        as_columnstore=false,
        post_hook=[
            "ALTER TABLE {{ this }} REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);",
            "{{  create_pk('ShipMode_SK') }}"
        ]
    )
}}

with cte as (
    SELECT DISTINCT
        Ship_Mode
    FROM {{ ref('superstore') }}
)
SELECT 
      ROW_NUMBER() OVER (ORDER BY (SELECT NULL))  as ShipMode_SK
      ,Ship_Mode
FROM cte



