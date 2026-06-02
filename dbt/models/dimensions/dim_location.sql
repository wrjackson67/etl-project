select
    row_number() over (order by borough, incident_zip, city) as location_id,
    borough,
    incident_zip,
    city
from (
    select distinct
        coalesce(borough, 'Unspecified') as borough,
        coalesce(incident_zip, 'Unknown') as incident_zip,
        coalesce(city, 'Unknown') as city
    from {{ ref('silver_311_requests_clean') }}
) location_values
