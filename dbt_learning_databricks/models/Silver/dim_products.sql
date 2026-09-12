{{config(
    materialized='table',
    catalog = var("catalog_map")[target.name]["silver"],
    schema =  var("schema_map")[target.name]["silver_schema"]
)}}

SELECT DISTINCT
    `Product ID` AS product_id,
    `Product Name` AS product_name,
    `Product Category` AS product_category
FROM {{ ref('bronze') }};