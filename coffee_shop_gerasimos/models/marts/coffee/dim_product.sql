{{ config(
    materialized = 'table'
) }}

select
    product_id,
    product_name,
    product_category,
    product_created_date
from {{ ref('stg_products') }}
