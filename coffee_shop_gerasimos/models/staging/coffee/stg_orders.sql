with source as (
    select *
    from {{source('coffee_shop','orders')}}
),

rename as (
    select
    id as order_id,
    created_at,
    customer_id,
    total,
    state
    from source
)

select order_id, created_at, customer_id, total, state
from rename