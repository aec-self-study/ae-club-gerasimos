with pageviews as (
    select *
    from {{ ref('stg_pageviews_stitched') }}
),

pageviews_with_session_flags as (
    select
        pageviews.*,
        case
            when timestamp_diff(
                pageviews.created_at,
                lag(pageviews.created_at) over (
                    partition by pageviews.visitor_id order by pageviews.created_at
                ),
                minute
            ) > 30
            or lag(pageviews.created_at) over (
                partition by pageviews.visitor_id order by pageviews.created_at
            ) is null
            then 1
            else 0
        end as is_new_session
    from pageviews
),

session_numbering as (
    select
        pageviews_with_session_flags.*,
        sum(is_new_session) over (
            partition by pageviews_with_session_flags.visitor_id 
            order by pageviews_with_session_flags.created_at
        ) as session_number
    from pageviews_with_session_flags
),

final as (
    select
        *,
        concat(visitor_id, '-', session_number) as session_id,
        min(created_at) over (
            partition by visitor_id, session_number
        ) as session_start_time,
        max(created_at) over (
            partition by visitor_id, session_number
        ) as session_end_time
    from session_numbering
)

select
    session_id,
    visitor_id,
    customer_id,
    page_url,
    device_type,
    created_at,
    session_start_time,
    session_end_time
from final
