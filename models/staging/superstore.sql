{{
    config(
        materialized='incremental', 
        unique_key="Row_ID"
      )
}}

SELECT
  Row_ID,
  Order_ID,
  Order_Date,
  Ship_Date,
  Ship_Mode,
  Customer_ID,
  Customer_Name,
  Segment,
  Country,
  City,
  State,
  Postal_Code,
  Region,
  Product_ID,
  Product_Name,
  Category,
  Sub_Category,
  Sales,
  Quantity,
  Discount,
  Profit
from {{ source('superstore_primary', 'superstore_primary') }}

{% if is_incremental() %}
WHERE Row_ID > (SELECT MAX(Row_ID) FROM {{ this }})
{% endif %}

-- post_hook="ALTER TABLE {{ this }} REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);"