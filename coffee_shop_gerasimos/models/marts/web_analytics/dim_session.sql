{{ config(
    materialized = 'table'
) }}

with pageviews as (
    select *
    from {{ ref('int_pageviews_with_sessions') }}
),

session_info as (
    select
        session_id,
        visitor_id,
        customer_id,
        array_agg(page_url order by created_at)[offset(0)] as entry_page,
        array_agg(page_url order by created_at desc)[offset(0)] as exit_page,
        count(distinct page_url) as number_of_distinct_pages,
        count(distinct device_type) > 1 as used_multiple_devices
    from pageviews
    group by session_id, visitor_id, customer_id
)

select *
from session_info
