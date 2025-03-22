with pageviews as (
    select *
    from {{ source('web_tracking', 'pageviews') }}
),

visitor_to_customer as (
    select
        visitor_id,
        customer_id
    from pageviews
    where customer_id is not null
    qualify row_number() over (partition by visitor_id order by customer_id) = 1
)

select
    coalesce(visitor_to_customer.customer_id, pageviews.visitor_id) as visitor_id,
    pageviews.customer_id,
    pageviews.page as page_url,
    pageviews.device_type,
    pageviews.timestamp as created_at
from pageviews
left join visitor_to_customer
    on pageviews.visitor_id = visitor_to_customer.visitor_id
