select
    fact.created_month,
    complaint.complaint_type,
    count(*) as request_count,
    round(avg(fact.close_time_hours), 2) as average_close_time_hours,
    round(
        percentile_cont(0.5) within group (order by fact.close_time_hours)::numeric,
        2
    ) as median_close_time_hours,
    count(*) - lag(count(*)) over (
        partition by complaint.complaint_type
        order by fact.created_month
    ) as month_over_month_request_change
from {{ ref('fact_service_requests') }} fact
join {{ ref('dim_complaint') }} complaint
    on fact.complaint_id = complaint.complaint_id
group by
    fact.created_month,
    complaint.complaint_type
