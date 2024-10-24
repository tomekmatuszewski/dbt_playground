{{
    config(
        materialized='incremental', 
        unique_key="Row_ID"
      )
}}

select
  {{ dbt_utils.generate_surrogate_key(['Order_ID', 'Row_ID']) }} as Sales_SK,
  Row_ID,
  Order_ID,
  date_dim.Date_SK as Date_Order_SK,
  date_dim_ship.Date_SK as Date_ShipMode_SK,
  ship_mode.ShipMode_SK,
  customer.Customer_SK,
  product.Product_SK,
  Sales,
  Quantity,
  Discount,  
  Profit

from {{ ref('superstore') }} source
LEFT JOIN {{ ref('date_dim' )}} date_dim ON CONVERT(datetime, source.Order_Date, 101)  = date_dim.date_day
LEFT JOIN {{ ref('date_dim' )}} date_dim_ship ON CONVERT(datetime, source.Ship_Date, 101) = date_dim_ship.date_day
LEFT JOIN {{ ref('shipmode_dim')}} ship_mode ON source.Ship_Mode = ship_mode.ship_mode 
LEFT JOIN {{ ref('customer_dim')}} customer ON source.Customer_ID = customer.Customer_ID AND source.Customer_Name = customer.Customer_Name AND customer.is_active = 1
LEFT JOIN {{ ref('product_dim') }} product ON source.Product_ID = product.Product_ID AND source.Product_Name = product.Product_Name AND product.is_active = 1

{% if is_incremental() %}
  WHERE Row_ID > (SELECT MAX(Row_ID) FROM {{ this }})
{% endif %}