{{ config(
    materialized = 'table'
) }}

with revenue_with_category as (
    select
        fct_order_revenue.order_created_at,
        dim_product.product_category,
        fct_order_revenue.item_price
    from {{ ref('fct_order_revenue') }} as fct_order_revenue
    left join {{ ref('dim_product') }} as dim_product
        on fct_order_revenue.product_id = dim_product.product_id
),

aggregated as (
    select
        date_trunc(revenue_with_category.order_created_at, week) as week_start,
        revenue_with_category.product_category,
        sum(revenue_with_category.item_price) as total_revenue
    from revenue_with_category
    group by week_start, product_category
)

select *
from aggregated
order by week_start, product_category

