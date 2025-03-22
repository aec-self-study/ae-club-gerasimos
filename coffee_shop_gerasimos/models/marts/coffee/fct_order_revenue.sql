{{ config(
    materialized = 'table'
) }}

with base as (
    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.product_id,
        orders.created_at as order_created_at,
        orders.customer_id,
        products.product_category,
        product_prices.price
    from {{ ref('stg_order_items') }} as order_items
    join {{ ref('stg_orders') }} as orders
        on order_items.order_id = orders.order_id
    join {{ ref('stg_products') }} products
        on order_items.product_id = products.product_id
    join {{ ref('stg_product_prices') }} product_prices
        on order_items.product_id = product_prices.product_id
        and orders.created_at between product_prices.created_at and coalesce(product_prices.ended_at, current_timestamp())
)

select
    order_id,
    customer_id,
    product_id,
    product_category,
    order_created_at,
    price as item_price
from base
