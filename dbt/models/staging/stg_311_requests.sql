select
    request_id,
    created_at,
    closed_at,
    created_month,
    agency,
    agency_name,
    complaint_type,
    descriptor,
    location_type,
    incident_zip,
    city,
    borough,
    status,
    close_time_hours,
    open_flag,
    has_data_quality_issue,
    source_file,
    loaded_at,
    cleaned_at
from {{ ref('silver_311_requests_clean') }}
where duplicate_row_number = 1
