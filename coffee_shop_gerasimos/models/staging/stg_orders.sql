with source as (
    select *
    from {{source('coffee_shop','orders')}}
)

select id, created_at, customer_id, total, state, zip
from source