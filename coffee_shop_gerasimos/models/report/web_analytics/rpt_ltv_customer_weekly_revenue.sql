{{ config(
    materialized = 'table'
) }}

with first_order as (
    select
        customer_id,
        min(order_created_at) as acquisition_date
    from {{ ref('fct_order_revenue') }}
    group by customer_id
),

orders_with_weeks as (
    select
        fct_order_revenue.customer_id,
        fct_order_revenue.item_price,
        date_diff(
            date_trunc(cast(fct_order_revenue.order_created_at as date), week),
            cast(first_order.acquisition_date as date),
            week
        ) + 1 as week_number
    from {{ ref('fct_order_revenue') }} as fct_order_revenue
    join first_order
        on fct_order_revenue.customer_id = first_order.customer_id
),

revenue_per_customer_week as (
    select
        customer_id,
        week_number,
        sum(item_price) as revenue
    from orders_with_weeks
    group by customer_id, week_number
),

weeks_generated as (
    select
        customer_id,
        week_number
    from {{ ref('dim_customer') }} as customers,
         unnest(generate_array(1, 52)) as week_number
),

ltv_weeks as (
    select
        weeks_generated.customer_id,
        weeks_generated.week_number,
        coalesce(revenue_per_customer_week.revenue, 0) as revenue
    from weeks_generated
    left join revenue_per_customer_week
        on weeks_generated.customer_id = revenue_per_customer_week.customer_id
        and weeks_generated.week_number = revenue_per_customer_week.week_number
),

ltv_final as (
    select
        customer_id,
        week_number,
        revenue,
        sum(revenue) over (
            partition by customer_id order by week_number
            rows between unbounded preceding and current row
        ) as cumulative_revenue
    from ltv_weeks
)

select *
from ltv_final
