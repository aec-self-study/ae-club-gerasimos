{{ config(
    materialized = 'table'
) }}

with pageviews as (
    select *
    from {{ ref('int_pageviews_with_sessions') }}
),

sessions as (
    select
        session_id,
        visitor_id,
        customer_id,
        min(session_start_time) as session_start_time,
        max(session_end_time) as session_end_time,
        timestamp_diff(max(session_end_time), min(session_start_time), second) as session_length_seconds,
        count(*) as number_of_pageviews,
        max(case when page_url like '%/checkout%' then 1 else 0 end) as ended_in_purchase
    from pageviews
    group by session_id, visitor_id, customer_id
)

select *
from sessions
