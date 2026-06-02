select
    agency.agency,
    agency.agency_name,
    count(*) as request_count,
    sum(case when fact.status = 'Closed' then 1 else 0 end) as closed_count,
    sum(fact.open_flag) as open_request_count,
    round(avg(fact.close_time_hours), 2) as average_close_time_hours,
    round(
        percentile_cont(0.5) within group (order by fact.close_time_hours)::numeric,
        2
    ) as median_close_time_hours,
    round(
        (sum(case when fact.status = 'Closed' then 1 else 0 end)::numeric / nullif(count(*), 0)) * 100,
        2
    ) as percent_closed
from {{ ref('fact_service_requests') }} fact
join {{ ref('dim_agency') }} agency
    on fact.agency_id = agency.agency_id
group by
    agency.agency,
    agency.agency_name
