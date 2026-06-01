-- Clean and standardize bronze 311 records into the silver layer.

DROP TABLE IF EXISTS silver_311_requests_clean;

CREATE TABLE silver_311_requests_clean AS
WITH source_data AS (
    SELECT
        NULLIF(TRIM(unique_key), '') AS request_id,
        NULLIF(TRIM(created_date), '') AS created_date_raw,
        NULLIF(TRIM(closed_date), '') AS closed_date_raw,
        NULLIF(TRIM(agency), '') AS agency,
        NULLIF(TRIM(agency_name), '') AS agency_name,
        NULLIF(TRIM(complaint_type), '') AS complaint_type,
        NULLIF(TRIM(descriptor), '') AS descriptor,
        NULLIF(TRIM(location_type), '') AS location_type,
        NULLIF(TRIM(incident_zip), '') AS incident_zip,
        NULLIF(TRIM(city), '') AS city,
        NULLIF(TRIM(status), '') AS status_raw,
        NULLIF(TRIM(resolution_description), '') AS resolution_description,
        NULLIF(TRIM(borough), '') AS borough_raw,
        NULLIF(TRIM(latitude), '') AS latitude_raw,
        NULLIF(TRIM(longitude), '') AS longitude_raw,
        source_file,
        loaded_at
    FROM bronze_311_requests
),
typed_data AS (
    SELECT
        request_id,
        created_date_raw,
        closed_date_raw,
        CASE
            WHEN created_date_raw ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}:\d{2} (AM|PM)$'
                THEN TO_TIMESTAMP(created_date_raw, 'MM/DD/YYYY HH12:MI:SS AM')
            ELSE NULL
        END AS created_at,
        CASE
            WHEN closed_date_raw ~ '^\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}:\d{2} (AM|PM)$'
                THEN TO_TIMESTAMP(closed_date_raw, 'MM/DD/YYYY HH12:MI:SS AM')
            ELSE NULL
        END AS closed_at,
        agency,
        agency_name,
        complaint_type,
        descriptor,
        location_type,
        incident_zip,
        INITCAP(city) AS city,
        status_raw,
        resolution_description,
        borough_raw,
        CASE
            WHEN UPPER(TRIM(borough_raw)) IN ('MANHATTAN', 'NEW YORK') THEN 'Manhattan'
            WHEN UPPER(TRIM(borough_raw)) = 'BROOKLYN' THEN 'Brooklyn'
            WHEN UPPER(TRIM(borough_raw)) = 'QUEENS' THEN 'Queens'
            WHEN UPPER(TRIM(borough_raw)) = 'BRONX' THEN 'Bronx'
            WHEN UPPER(TRIM(borough_raw)) IN ('STATEN ISLAND', 'STATEN IS') THEN 'Staten Island'
            ELSE 'Unspecified'
        END AS borough,
        CASE
            WHEN UPPER(TRIM(status_raw)) IN ('CLOSED', 'CLOSE') THEN 'Closed'
            WHEN UPPER(TRIM(status_raw)) IN ('OPEN', 'IN PROGRESS', 'PENDING', 'STARTED', 'ASSIGNED') THEN 'Open'
            ELSE 'Other'
        END AS status,
        CASE
            WHEN latitude_raw ~ '^-?\d+(\.\d+)?$' THEN latitude_raw::NUMERIC
            ELSE NULL
        END AS latitude,
        CASE
            WHEN longitude_raw ~ '^-?\d+(\.\d+)?$' THEN longitude_raw::NUMERIC
            ELSE NULL
        END AS longitude,
        source_file,
        loaded_at
    FROM source_data
),
deduped_data AS (
    SELECT
        *,
        COUNT(*) OVER (PARTITION BY request_id) AS duplicate_request_count,
        ROW_NUMBER() OVER (
            PARTITION BY request_id
            ORDER BY created_at DESC NULLS LAST, loaded_at DESC NULLS LAST
        ) AS duplicate_row_number
    FROM typed_data
)
SELECT
    request_id,
    created_date_raw,
    closed_date_raw,
    created_at,
    closed_at,
    DATE_TRUNC('month', created_at)::DATE AS created_month,
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
    CASE
        WHEN created_at IS NOT NULL
            AND closed_at IS NOT NULL
            AND closed_at >= created_at
            THEN ROUND((EXTRACT(EPOCH FROM (closed_at - created_at)) / 3600)::NUMERIC, 2)
        ELSE NULL
    END AS close_time_hours,
    CASE WHEN status = 'Closed' THEN 0 ELSE 1 END AS open_flag,
    duplicate_request_count,
    duplicate_row_number,
    duplicate_request_count > 1 AS is_duplicate_request_id,
    request_id IS NULL AS missing_request_id_flag,
    created_at IS NULL AS invalid_created_date_flag,
    closed_at IS NOT NULL AND created_at IS NOT NULL AND closed_at < created_at AS invalid_close_date_flag,
    agency IS NULL AS missing_agency_flag,
    complaint_type IS NULL AS missing_complaint_type_flag,
    borough = 'Unspecified' AS missing_or_unspecified_borough_flag,
    latitude IS NOT NULL AND NOT (latitude BETWEEN -90 AND 90) AS invalid_latitude_flag,
    longitude IS NOT NULL AND NOT (longitude BETWEEN -180 AND 180) AS invalid_longitude_flag,
    CASE
        WHEN request_id IS NULL
            OR created_at IS NULL
            OR (closed_at IS NOT NULL AND created_at IS NOT NULL AND closed_at < created_at)
            OR agency IS NULL
            OR complaint_type IS NULL
            OR borough = 'Unspecified'
            OR (latitude IS NOT NULL AND NOT (latitude BETWEEN -90 AND 90))
            OR (longitude IS NOT NULL AND NOT (longitude BETWEEN -180 AND 180))
            THEN TRUE
        ELSE FALSE
    END AS has_data_quality_issue,
    source_file,
    loaded_at,
    CURRENT_TIMESTAMP AS cleaned_at
FROM deduped_data;

CREATE INDEX IF NOT EXISTS idx_silver_311_request_id
ON silver_311_requests_clean (request_id);

CREATE INDEX IF NOT EXISTS idx_silver_311_created_month
ON silver_311_requests_clean (created_month);

CREATE INDEX IF NOT EXISTS idx_silver_311_borough
ON silver_311_requests_clean (borough);

CREATE INDEX IF NOT EXISTS idx_silver_311_agency
ON silver_311_requests_clean (agency);

CREATE INDEX IF NOT EXISTS idx_silver_311_complaint_type
ON silver_311_requests_clean (complaint_type);
