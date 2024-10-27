{{
    config(
        materialized='table', 
        on_schema_change='append_new_columns',
        as_columnstore=false,
        contract={'enforced': true},
        post_hook=[
            "ALTER TABLE {{ this }} REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);",
            "ALTER TABLE {{ this }} ADD CONSTRAINT Customer_PK PRIMARY KEY (Customer_SK);"
        ],
    )
}}

with cte as (
    SELECT
       CONVERT(datetime, Order_Date, 101) AS Order_Date_DT
      ,Customer_ID
      ,Customer_Name
      ,Segment
      ,Country
      ,City
      ,State
      ,Postal_Code
      ,Region
  FROM {{ ref("superstore")}}
),
cte_with_dates as (
    SELECT
       Customer_ID
      ,Customer_Name
      ,Segment
      ,Country
      ,City
      ,State
      ,Postal_Code
      ,Region
      ,Order_Date_DT as start_date
      ,LEAD(Order_Date_DT) OVER(PARTITION BY Customer_ID ORDER BY Order_Date_DT ) as end_date
    FROM cte
),
consecutive_rows as (
SELECT
    *,
    IIF(end_date is null, 1, 0) as is_current,
     ROW_NUMBER() OVER (PARTITION BY Customer_ID  ORDER BY start_date) 
               - ROW_NUMBER() OVER (PARTITION BY Customer_ID, Customer_Name, Segment, Country, City, State, Postal_Code, Region, start_date  ORDER BY start_date) AS grp
FROM cte_with_dates
),
cte_with_final_dates as (
SELECT
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    State,
    Postal_Code,
    Region,
    MIN(start_date) AS valid_from,
    CASE 
        WHEN MAX(is_current) = 1 THEN CONVERT(datetime, '12/31/9999', 101) 
        ELSE MAX(end_date) END AS valid_to,
    MAX(is_current) AS is_active
FROM consecutive_rows
GROUP BY Customer_ID, Customer_Name, Segment, Country, City, State, Postal_Code, Region, grp
)
SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL))  as Customer_SK,
    *
FROM cte_with_final_dates where valid_from <> valid_to


      