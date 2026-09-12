--{{ config(materialized='view') }}
-- Block layer configuration for the bronze model highest priority of the configuration is given to the block layer configuration. This means that if there are any conflicting configurations between the block layer and the properties.yml file, the block layer configuration will take precedence. #}

--  By using the below query generic test on the transaction_id column is performed to check for uniqueness and not null values. 
--  The test is failing due to the presence of duplicate and null values in the transaction_id column. 
    {# SELECT *
FROM {{ source('source', 'sales') }} #}

-- Removing the duplicate and null values from the transaction_id column to make the test pass.

--============================================================
    -- Now, I want to create a incremenal load of the data to 
        -- create the fact_sales table in the silver layer.
--============================================================


--===========================================================================
    -- Remove duplicates and null values from the transaction_id column to make the test pass.
--===========================================================================
{{ config(
    tags=['silver'],
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='transaction_id',
    catalog=var("catalog_map")[target.name]["silver"],
    schema=var("schema_map")[target.name]["silver_schema"]
    ) }}

    WITH ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY `Transaction Id`
            ORDER BY `Transaction Id`
        ) AS rn
    FROM {{ ref('bronze') }}
    where `Transaction Id` is not null
    {% if is_incremental() %}
    and `Date` > (select max(`Date`) from {{ this }})
    {% endif %}

)

--==========================================================================
    --Final query to create the fact_sales table in the silver layer.
--==========================================================================
SELECT
    CAST(`Transaction Id` AS STRING) AS `transaction_id`,
    CAST(`Date` AS DATE) AS `date`,
    CAST(`Product Id` AS STRING) AS `product_id`,
    CAST(`Quantity` AS INT) AS `quantity`,

    CAST(
        REPLACE(`PPU`, ',', '')
        AS DECIMAL(18,2)
    ) AS `ppu`,
    CAST(
        REPLACE(`Amount`, ',', '')
        AS DECIMAL(18,2)
    ) AS `amount`,
    CAST(`Customer Id` AS STRING) AS `customer_id`,
    CAST(`Region` AS STRING) AS `region`

FROM ranked
WHERE rn = 1
