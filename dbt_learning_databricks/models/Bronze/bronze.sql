config(
    tags=['bronze']
) 
 
 
 SELECT
        *
    FROM {{ source('source', 'sales') }}
