select
    row_number() over (order by agency, agency_name) as agency_id,
    agency,
    agency_name
from (
    select distinct
        coalesce(agency, 'Unknown') as agency,
        coalesce(agency_name, 'Unknown') as agency_name
    from {{ ref('silver_311_requests_clean') }}
) agency_values
