{{confing(materialized='view')}}
-- Block layer configuration for the bronze model highest priority of the configuration is given to the block layer configuration. This means that if there are any conflicting configurations between the block layer and the properties.yml file, the block layer configuration will take precedence.


SELECT * 
FROM {{ source('source', 'raw_rfm_sales_transactions') }}