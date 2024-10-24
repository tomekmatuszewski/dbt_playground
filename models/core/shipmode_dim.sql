{{
    config(materialized='table')
}}

with cte as (
    SELECT DISTINCT
        Ship_Mode
    FROM {{ ref('superstore') }}
)
SELECT 
      {{ dbt_utils.generate_surrogate_key(['Ship_Mode']) }} as ShipMode_SK
      ,Ship_Mode
FROM cte



