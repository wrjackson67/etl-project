-- Create the service request fact table.

DROP TABLE IF EXISTS fact_service_requests;

CREATE TABLE fact_service_requests AS
SELECT
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
FROM silver_311_requests_clean silver
LEFT JOIN dim_agency agency
    ON COALESCE(silver.agency, 'Unknown') = agency.agency
    AND COALESCE(silver.agency_name, 'Unknown') = agency.agency_name
LEFT JOIN dim_location location
    ON COALESCE(silver.borough, 'Unspecified') = location.borough
    AND COALESCE(silver.incident_zip, 'Unknown') = location.incident_zip
    AND COALESCE(silver.city, 'Unknown') = location.city
LEFT JOIN dim_complaint complaint
    ON COALESCE(silver.complaint_type, 'Unknown') = complaint.complaint_type
    AND COALESCE(silver.descriptor, 'Unknown') = complaint.descriptor
    AND COALESCE(silver.location_type, 'Unknown') = complaint.location_type;

ALTER TABLE fact_service_requests
ADD CONSTRAINT pk_fact_service_requests PRIMARY KEY (request_id);

ALTER TABLE fact_service_requests
ADD CONSTRAINT fk_fact_agency
FOREIGN KEY (agency_id) REFERENCES dim_agency (agency_id);

ALTER TABLE fact_service_requests
ADD CONSTRAINT fk_fact_location
FOREIGN KEY (location_id) REFERENCES dim_location (location_id);

ALTER TABLE fact_service_requests
ADD CONSTRAINT fk_fact_complaint
FOREIGN KEY (complaint_id) REFERENCES dim_complaint (complaint_id);

CREATE INDEX idx_fact_service_requests_created_month
ON fact_service_requests (created_month);

CREATE INDEX idx_fact_service_requests_agency_id
ON fact_service_requests (agency_id);

CREATE INDEX idx_fact_service_requests_location_id
ON fact_service_requests (location_id);

CREATE INDEX idx_fact_service_requests_complaint_id
ON fact_service_requests (complaint_id);
