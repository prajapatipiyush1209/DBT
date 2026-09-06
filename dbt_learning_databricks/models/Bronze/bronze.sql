--{{ config(materialized='view') }}
-- Block layer configuration for the bronze model highest priority of the configuration is given to the block layer configuration. This means that if there are any conflicting configurations between the block layer and the properties.yml file, the block layer configuration will take precedence. #}

--  By using the below query generic test on the transaction_id column is performed to check for uniqueness and not null values. 
--  The test is failing due to the presence of duplicate and null values in the transaction_id column. 
    {# SELECT *
FROM {{ source('source', 'sales') }} #}

-- Removing the duplicate and null values from the transaction_id column to make the test pass.
    WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY `Transaction Id`
            ORDER BY `Transaction Id`
        ) AS rn
    FROM {{ source('source', 'sales') }}
    where `Transaction Id` is not null
)

SELECT *
FROM ranked
WHERE rn = 1