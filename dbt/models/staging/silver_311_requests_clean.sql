with source_data as (
    select
        nullif(trim(unique_key), '') as request_id,
        nullif(trim(created_date), '') as created_date_raw,
        nullif(trim(closed_date), '') as closed_date_raw,
        nullif(trim(agency), '') as agency,
        nullif(trim(agency_name), '') as agency_name,
        nullif(trim(complaint_type), '') as complaint_type,
        nullif(trim(descriptor), '') as descriptor,
        nullif(trim(location_type), '') as location_type,
        nullif(trim(incident_zip), '') as incident_zip,
        nullif(trim(city), '') as city,
        nullif(trim(status), '') as status_raw,
        nullif(trim(resolution_description), '') as resolution_description,
        nullif(trim(borough), '') as borough_raw,
        nullif(trim(latitude), '') as latitude_raw,
        nullif(trim(longitude), '') as longitude_raw,
        source_file,
        loaded_at
    from {{ source('public', 'bronze_311_requests') }}
),

typed_data as (
    select
        request_id,
        created_date_raw,
        closed_date_raw,
        case
            when created_date_raw ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}:\d{2} (AM|PM)$'
                then to_timestamp(created_date_raw, 'MM/DD/YYYY HH12:MI:SS AM')
            else null
        end as created_at,
        case
            when closed_date_raw ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}:\d{2} (AM|PM)$'
                then to_timestamp(closed_date_raw, 'MM/DD/YYYY HH12:MI:SS AM')
            else null
        end as closed_at,
        agency,
        agency_name,
        complaint_type,
        descriptor,
        location_type,
        incident_zip,
        initcap(city) as city,
        status_raw,
        resolution_description,
        borough_raw,
        case
            when upper(trim(borough_raw)) in ('MANHATTAN', 'NEW YORK') then 'Manhattan'
            when upper(trim(borough_raw)) = 'BROOKLYN' then 'Brooklyn'
            when upper(trim(borough_raw)) = 'QUEENS' then 'Queens'
            when upper(trim(borough_raw)) = 'BRONX' then 'Bronx'
            when upper(trim(borough_raw)) in ('STATEN ISLAND', 'STATEN IS') then 'Staten Island'
            else 'Unspecified'
        end as borough,
        case
            when upper(trim(status_raw)) in ('CLOSED', 'CLOSE') then 'Closed'
            when upper(trim(status_raw)) in ('OPEN', 'IN PROGRESS', 'PENDING', 'STARTED', 'ASSIGNED') then 'Open'
            else 'Other'
        end as status,
        case
            when latitude_raw ~ '^-?\d+(\.\d+)?$' then latitude_raw::numeric
            else null
        end as latitude,
        case
            when longitude_raw ~ '^-?\d+(\.\d+)?$' then longitude_raw::numeric
            else null
        end as longitude,
        source_file,
        loaded_at
    from source_data
),

deduped_data as (
    select
        *,
        count(*) over (partition by request_id) as duplicate_request_count,
        row_number() over (
            partition by request_id
            order by created_at desc nulls last, loaded_at desc nulls last
        ) as duplicate_row_number
    from typed_data
)

select
    request_id,
    created_date_raw,
    closed_date_raw,
    created_at,
    closed_at,
    date_trunc('month', created_at)::date as created_month,
    agency,
    agency_name,
    complaint_type,
    descriptor,
    location_type,
    incident_zip,
    city,
    borough,
    borough_raw,
    status,
    status_raw,
    resolution_description,
    latitude,
    longitude,
    case
        when created_at is not null
            and closed_at is not null
            and closed_at >= created_at
            then round((extract(epoch from (closed_at - created_at)) / 3600)::numeric, 2)
        else null
    end as close_time_hours,
    case when status = 'Closed' then 0 else 1 end as open_flag,
    duplicate_request_count,
    duplicate_row_number,
    duplicate_request_count > 1 as is_duplicate_request_id,
    request_id is null as missing_request_id_flag,
    created_at is null as invalid_created_date_flag,
    closed_at is not null and created_at is not null and closed_at < created_at as invalid_close_date_flag,
    agency is null as missing_agency_flag,
    complaint_type is null as missing_complaint_type_flag,
    borough = 'Unspecified' as missing_or_unspecified_borough_flag,
    latitude is not null and not (latitude between -90 and 90) as invalid_latitude_flag,
    longitude is not null and not (longitude between -180 and 180) as invalid_longitude_flag,
    case
        when request_id is null
            or created_at is null
            or (closed_at is not null and created_at is not null and closed_at < created_at)
            or agency is null
            or complaint_type is null
            or borough = 'Unspecified'
            or (latitude is not null and not (latitude between -90 and 90))
            or (longitude is not null and not (longitude between -180 and 180))
            then true
        else false
    end as has_data_quality_issue,
    source_file,
    loaded_at,
    current_timestamp as cleaned_at
from deduped_data
