with source as (
    select *
    from {{source('coffee_shop','customers')}}
)

select id, name, email
from source