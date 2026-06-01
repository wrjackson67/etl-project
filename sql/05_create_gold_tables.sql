-- Create analytics-ready gold reporting tables.

DROP TABLE IF EXISTS gold_monthly_borough_summary;
DROP TABLE IF EXISTS gold_agency_performance;
DROP TABLE IF EXISTS gold_complaint_trends;
DROP TABLE IF EXISTS gold_data_quality_report;

CREATE TABLE gold_monthly_borough_summary AS
SELECT
    fact.created_month,
    location.borough,
    COUNT(*) AS request_count,
    SUM(CASE WHEN fact.status = 'Closed' THEN 1 ELSE 0 END) AS closed_count,
    SUM(fact.open_flag) AS open_request_count,
    ROUND(AVG(fact.close_time_hours), 2) AS average_close_time_hours,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fact.close_time_hours)::NUMERIC,
        2
    ) AS median_close_time_hours,
    ROUND(
        (SUM(CASE WHEN fact.status = 'Closed' THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(*), 0)) * 100,
        2
    ) AS percent_closed
FROM fact_service_requests fact
JOIN dim_location location
    ON fact.location_id = location.location_id
GROUP BY
    fact.created_month,
    location.borough;

CREATE INDEX idx_gold_monthly_borough_summary_month
ON gold_monthly_borough_summary (created_month);

CREATE INDEX idx_gold_monthly_borough_summary_borough
ON gold_monthly_borough_summary (borough);

CREATE TABLE gold_agency_performance AS
SELECT
    agency.agency,
    agency.agency_name,
    COUNT(*) AS request_count,
    SUM(CASE WHEN fact.status = 'Closed' THEN 1 ELSE 0 END) AS closed_count,
    SUM(fact.open_flag) AS open_request_count,
    ROUND(AVG(fact.close_time_hours), 2) AS average_close_time_hours,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fact.close_time_hours)::NUMERIC,
        2
    ) AS median_close_time_hours,
    ROUND(
        (SUM(CASE WHEN fact.status = 'Closed' THEN 1 ELSE 0 END)::NUMERIC / NULLIF(COUNT(*), 0)) * 100,
        2
    ) AS percent_closed
FROM fact_service_requests fact
JOIN dim_agency agency
    ON fact.agency_id = agency.agency_id
GROUP BY
    agency.agency,
    agency.agency_name;

CREATE INDEX idx_gold_agency_performance_agency
ON gold_agency_performance (agency);

CREATE TABLE gold_complaint_trends AS
SELECT
    fact.created_month,
    complaint.complaint_type,
    COUNT(*) AS request_count,
    ROUND(AVG(fact.close_time_hours), 2) AS average_close_time_hours,
    ROUND(
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fact.close_time_hours)::NUMERIC,
        2
    ) AS median_close_time_hours,
    COUNT(*) - LAG(COUNT(*)) OVER (
        PARTITION BY complaint.complaint_type
        ORDER BY fact.created_month
    ) AS month_over_month_request_change
FROM fact_service_requests fact
JOIN dim_complaint complaint
    ON fact.complaint_id = complaint.complaint_id
GROUP BY
    fact.created_month,
    complaint.complaint_type;

CREATE INDEX idx_gold_complaint_trends_month
ON gold_complaint_trends (created_month);

CREATE INDEX idx_gold_complaint_trends_complaint_type
ON gold_complaint_trends (complaint_type);

CREATE TABLE gold_data_quality_report AS
SELECT
    CURRENT_DATE AS run_date,
    COUNT(*) AS total_records,
    COUNT(*) - COUNT(DISTINCT request_id) AS duplicate_id_count,
    SUM(missing_request_id_flag::INT) AS missing_request_id_count,
    SUM(invalid_created_date_flag::INT) AS invalid_created_date_count,
    SUM(invalid_close_date_flag::INT) AS invalid_date_count,
    SUM(missing_agency_flag::INT) AS missing_agency_count,
    SUM(missing_complaint_type_flag::INT) AS missing_complaint_type_count,
    SUM(missing_or_unspecified_borough_flag::INT) AS missing_borough_count,
    SUM(CASE WHEN incident_zip IS NULL THEN 1 ELSE 0 END) AS missing_zip_count,
    SUM(CASE WHEN closed_at IS NULL THEN 1 ELSE 0 END) AS missing_closed_date_count,
    SUM(invalid_latitude_flag::INT) AS invalid_latitude_count,
    SUM(invalid_longitude_flag::INT) AS invalid_longitude_count,
    SUM(has_data_quality_issue::INT) AS records_with_quality_issues,
    ROUND(
        (1 - (SUM(has_data_quality_issue::INT)::NUMERIC / NULLIF(COUNT(*), 0))) * 100,
        2
    ) AS data_quality_score
FROM silver_311_requests_clean;
