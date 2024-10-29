{{
    config(
        materialized='table',
        on_schema_change='append_new_columns',
        as_columnstore=false,
        post_hook=[
            "ALTER TABLE {{ this }} REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);",
            "{{ create_pk('Product_SK') }}"
        ]
    )
}}

with cte as (
    SELECT 
      CONVERT(datetime, Order_Date, 101) AS createdAt
      ,Product_ID
      ,Product_Name
      ,Category
      ,Sub_Category
  FROM {{ ref('superstore') }}
),
cte_with_dates as (
    SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
   createdAt as start_date,
    LEAD(createdAt) OVER(PARTITION BY Product_ID ORDER BY createdAt ) as end_date
    FROM cte
),
consecutive_rows as (
SELECT
    *,
    IIF(end_date is null, 1, 0) as is_current,
     ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY start_date) 
               - ROW_NUMBER() OVER (PARTITION BY Product_ID, Product_Name  ORDER BY start_date) AS grp
FROM cte_with_dates

),
final as (
SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    MIN(start_date) AS valid_from,
    CASE 
        WHEN MAX(is_current) = 1 THEN CONVERT(datetime, '12/31/9999', 101) 
        ELSE MAX(end_date) END AS valid_to,
    MAX(is_current) AS is_active 
FROM consecutive_rows
GROUP BY Product_ID, Product_Name, Category, Sub_Category, grp
)
SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as Product_SK,
    *
FROM final where valid_from <> valid_to


