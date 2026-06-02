select
    silver.request_id,
    silver.created_at,
    silver.closed_at,
    silver.created_month,
    agency.agency_id,
    location.location_id,
    complaint.complaint_id,
    silver.status,
    silver.close_time_hours,
    silver.open_flag,
    silver.has_data_quality_issue,
    silver.invalid_created_date_flag,
    silver.invalid_close_date_flag,
    silver.missing_agency_flag,
    silver.missing_complaint_type_flag,
    silver.missing_or_unspecified_borough_flag,
    silver.is_duplicate_request_id
from {{ ref('silver_311_requests_clean') }} silver
left join {{ ref('dim_agency') }} agency
    on coalesce(silver.agency, 'Unknown') = agency.agency
    and coalesce(silver.agency_name, 'Unknown') = agency.agency_name
left join {{ ref('dim_location') }} location
    on coalesce(silver.borough, 'Unspecified') = location.borough
    and coalesce(silver.incident_zip, 'Unknown') = location.incident_zip
    and coalesce(silver.city, 'Unknown') = location.city
left join {{ ref('dim_complaint') }} complaint
    on coalesce(silver.complaint_type, 'Unknown') = complaint.complaint_type
    and coalesce(silver.descriptor, 'Unknown') = complaint.descriptor
    and coalesce(silver.location_type, 'Unknown') = complaint.location_type
where silver.duplicate_row_number = 1
