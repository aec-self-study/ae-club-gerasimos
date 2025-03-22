with source as (
    select *
    from {{source('coffee_shop','products')}}
),

rename as (
    select 
    id as product_id,
    name as product_name,
    category as product_category,
    created_at as product_created_date
    from source
)

select product_id, product_name, product_category, product_created_date
from rename