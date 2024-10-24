{{
    config(materialized='table')
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
     ROW_NUMBER() OVER (PARTITION BY Product_ID ORDER BY Start_Date) 
               - ROW_NUMBER() OVER (PARTITION BY Product_ID, Product_Name ORDER BY Start_Date) AS grp
FROM cte_with_dates

)
SELECT
    {{ dbt_utils.generate_surrogate_key(['Product_ID']) }} as Product_SK,
    Product_ID,
    Product_Name,
    Category,
    Sub_Category,
    MIN(start_date) AS valid_from,
    CASE 
        WHEN MAX(is_current) = 1 THEN NULL
        ELSE MAX(end_date) END AS valid_to,
    MAX(is_current) AS is_active 
FROM consecutive_rows
GROUP BY Product_ID, Product_Name, Category, Sub_Category, grp



