{{ 
  config(
    materialized = 'table'
  ) 
}}

with customers as (
    select *
    from {{ ref('stg_customers') }}
),

first_orders as (
    select
        customer_id,
        min(created_at) as first_order_date
    from {{ ref('stg_orders') }} as orders
    group by customer_id
),

order_summary as (
    select
        customer_id,
        count(*) as total_orders,
        sum(total) as total_spent
    from {{ ref('stg_orders') }} as orders
    group by customer_id
)

select
    customers.customer_id,
    customers.has_email,
    first_orders.first_order_date,
    order_summary.total_orders,
    order_summary.total_spent,
    case 
        when order_summary.total_orders > 1 then true 
        else false 
    end as is_returning_customer
from customers
left join first_orders
    on customers.customer_id = first_orders.customer_id
left join order_summary
    on customers.customer_id = order_summary.customer_id
