{% macro create_fk(column_name, ref_model) %}

USE hd_final_project;
ALTER TABLE dbo_core.sales_fact ADD FOREIGN KEY (Customer_SK) REFERENCES dbo_core.customer_dim(Customer_SK);
ALTER TABLE dbo_core.sales_fact ADD FOREIGN KEY (Product_SK) REFERENCES dbo_core.product_dim(Product_SK);
ALTER TABLE dbo_core.sales_fact ADD FOREIGN KEY (Date_Order_SK) REFERENCES dbo_core.date_dim(Date_SK);
ALTER TABLE dbo_core.sales_fact ADD FOREIGN KEY (Date_ShipMode_SK) REFERENCES dbo_core.date_dim(Date_SK);
ALTER TABLE dbo_core.sales_fact ADD FOREIGN KEY (ShipMode_SK) REFERENCES dbo_core.shipmode_dim(ShipMode_SK);




{% endmacro %}