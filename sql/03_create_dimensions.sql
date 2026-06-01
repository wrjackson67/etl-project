-- Create agency, location, and complaint dimension tables.

DROP TABLE IF EXISTS fact_service_requests;
DROP TABLE IF EXISTS dim_agency;
DROP TABLE IF EXISTS dim_location;
DROP TABLE IF EXISTS dim_complaint;

CREATE TABLE dim_agency AS
SELECT
    ROW_NUMBER() OVER (ORDER BY agency, agency_name) AS agency_id,
    agency,
    agency_name
FROM (
    SELECT DISTINCT
        COALESCE(agency, 'Unknown') AS agency,
        COALESCE(agency_name, 'Unknown') AS agency_name
    FROM silver_311_requests_clean
) agency_values;

ALTER TABLE dim_agency
ADD CONSTRAINT pk_dim_agency PRIMARY KEY (agency_id);

CREATE UNIQUE INDEX idx_dim_agency_natural_key
ON dim_agency (agency, agency_name);

CREATE TABLE dim_location AS
SELECT
    ROW_NUMBER() OVER (ORDER BY borough, incident_zip, city) AS location_id,
    borough,
    incident_zip,
    city
FROM (
    SELECT DISTINCT
        COALESCE(borough, 'Unspecified') AS borough,
        COALESCE(incident_zip, 'Unknown') AS incident_zip,
        COALESCE(city, 'Unknown') AS city
    FROM silver_311_requests_clean
) location_values;

ALTER TABLE dim_location
ADD CONSTRAINT pk_dim_location PRIMARY KEY (location_id);

CREATE UNIQUE INDEX idx_dim_location_natural_key
ON dim_location (borough, incident_zip, city);

CREATE TABLE dim_complaint AS
SELECT
    ROW_NUMBER() OVER (ORDER BY complaint_type, descriptor, location_type) AS complaint_id,
    complaint_type,
    descriptor,
    location_type
FROM (
    SELECT DISTINCT
        COALESCE(complaint_type, 'Unknown') AS complaint_type,
        COALESCE(descriptor, 'Unknown') AS descriptor,
        COALESCE(location_type, 'Unknown') AS location_type
    FROM silver_311_requests_clean
) complaint_values;

ALTER TABLE dim_complaint
ADD CONSTRAINT pk_dim_complaint PRIMARY KEY (complaint_id);

CREATE UNIQUE INDEX idx_dim_complaint_natural_key
ON dim_complaint (complaint_type, descriptor, location_type);
