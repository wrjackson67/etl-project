select
    row_number() over (order by complaint_type, descriptor, location_type) as complaint_id,
    complaint_type,
    descriptor,
    location_type
from (
    select distinct
        coalesce(complaint_type, 'Unknown') as complaint_type,
        coalesce(descriptor, 'Unknown') as descriptor,
        coalesce(location_type, 'Unknown') as location_type
    from {{ ref('silver_311_requests_clean') }}
) complaint_values
