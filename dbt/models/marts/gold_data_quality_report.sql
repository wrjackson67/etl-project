select
    current_date as run_date,
    count(*) as total_records,
    count(*) - count(distinct request_id) as duplicate_id_count,
    sum(missing_request_id_flag::int) as missing_request_id_count,
    sum(invalid_created_date_flag::int) as invalid_created_date_count,
    sum(invalid_close_date_flag::int) as invalid_date_count,
    sum(missing_agency_flag::int) as missing_agency_count,
    sum(missing_complaint_type_flag::int) as missing_complaint_type_count,
    sum(missing_or_unspecified_borough_flag::int) as missing_borough_count,
    sum(case when incident_zip is null then 1 else 0 end) as missing_zip_count,
    sum(case when closed_at is null then 1 else 0 end) as missing_closed_date_count,
    sum(invalid_latitude_flag::int) as invalid_latitude_count,
    sum(invalid_longitude_flag::int) as invalid_longitude_count,
    sum(has_data_quality_issue::int) as records_with_quality_issues,
    round(
        (1 - (sum(has_data_quality_issue::int)::numeric / nullif(count(*), 0))) * 100,
        2
    ) as data_quality_score
from {{ ref('silver_311_requests_clean') }}
