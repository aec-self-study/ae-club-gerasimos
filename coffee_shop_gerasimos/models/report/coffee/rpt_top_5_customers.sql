{{ config(
    materialized = 'table'
) }}

with orders_with_metadata as (
    select
        fct_order_revenue.customer_id,
        fct_order_revenue.order_created_at,
        count(distinct fct_order_revenue.order_id) over (partition by fct_order_revenue.customer_id) as number_of_orders,
        min(fct_order_revenue.order_created_at) over (partition by fct_order_revenue.customer_id) as first_order_at
    from {{ ref('fct_order_revenue') }} as fct_order_revenue
),

final as (
    select distinct
        dim_customer.customer_id,
        dim_customer.has_email,
        orders_with_metadata.first_order_at,
        orders_with_metadata.number_of_orders
    from orders_with_metadata
    join {{ ref('dim_customer') }} as dim_customer
        on orders_with_metadata.customer_id = dim_customer.customer_id
)

select *
from final
order by first_order_at
limit 5
