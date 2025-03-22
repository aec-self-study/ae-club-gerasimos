with source as (
    select *
    from {{source('coffee_shop','customers')}}
),

rename as (
    select 
    id as customer_id,
    case 
        when email is not null and email != '' then true
        else false end 
    as has_email
    from source
)

select customer_id, has_email
from rename