select 
customers.id as customer_id,
customers.name,
customers.email,
min(created_at) over (partition by orders.id) as first_order_at,
count(*) over (partition by customers.id) as number_of_orders
from {{ref('stg_customers')}} as customers
left join {{ref('stg_orders')}} as orders
on ( customers.id = orders.customer_id )
order by first_order_at
limit 5