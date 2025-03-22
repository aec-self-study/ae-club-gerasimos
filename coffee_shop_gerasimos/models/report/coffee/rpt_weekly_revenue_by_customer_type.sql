{{ config(
    materialized = 'table'
) }}

with first_order_dates as (
    select
        customer_id,
        min(order_created_at) as first_order_date
    from {{ ref('fct_order_revenue') }} as fct_order_revenue
    group by customer_id
),

classified_orders as (
    select
        fct_order_revenue.order_created_at,
        fct_order_revenue.customer_id,
        fct_order_revenue.item_price,
        case
            when fct_order_revenue.order_created_at <= timestamp_add(first_order_dates.first_order_date, interval 7 day) then 'new'
            else 'returning'
        end as customer_type
    from {{ ref('fct_order_revenue') }} as fct_order_revenue
    join first_order_dates
        on fct_order_revenue.customer_id = first_order_dates.customer_id
),

aggregated as (
    select
        date_trunc(classified_orders.order_created_at, week) as week_start,
        classified_orders.customer_type,
        sum(classified_orders.item_price) as total_revenue
    from classified_orders
    group by week_start, customer_type
)

select *
from aggregated
order by week_start, customer_type

