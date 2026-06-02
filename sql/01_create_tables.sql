-- Create base and operational tables for the NYC 311 pipeline.

CREATE TABLE IF NOT EXISTS pipeline_run_log (
    run_id BIGSERIAL PRIMARY KEY,
    pipeline_name TEXT NOT NULL DEFAULT 'nyc_311_batch_elt',
    status TEXT NOT NULL DEFAULT 'running',
    source_file TEXT,
    run_started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    run_finished_at TIMESTAMP,
    duration_seconds NUMERIC(12, 2),
    last_loaded_request_id TEXT,
    rows_extracted INTEGER NOT NULL DEFAULT 0,
    rows_loaded INTEGER NOT NULL DEFAULT 0,
    rows_rejected INTEGER NOT NULL DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS bronze_311_requests (
    unique_key TEXT,
    created_date TEXT,
    closed_date TEXT,
    agency TEXT,
    agency_name TEXT,
    complaint_type TEXT,
    descriptor TEXT,
    additional_details TEXT,
    location_type TEXT,
    incident_zip TEXT,
    incident_address TEXT,
    street_name TEXT,
    cross_street_1 TEXT,
    cross_street_2 TEXT,
    intersection_street_1 TEXT,
    intersection_street_2 TEXT,
    address_type TEXT,
    city TEXT,
    landmark TEXT,
    facility_type TEXT,
    status TEXT,
    due_date TEXT,
    resolution_description TEXT,
    resolution_action_updated_date TEXT,
    community_board TEXT,
    council_district TEXT,
    police_precinct TEXT,
    bbl TEXT,
    borough TEXT,
    x_coordinate_state_plane TEXT,
    y_coordinate_state_plane TEXT,
    open_data_channel_type TEXT,
    park_facility_name TEXT,
    park_borough TEXT,
    vehicle_type TEXT,
    taxi_company_borough TEXT,
    taxi_pick_up_location TEXT,
    bridge_highway_name TEXT,
    bridge_highway_direction TEXT,
    road_ramp TEXT,
    bridge_highway_segment TEXT,
    latitude TEXT,
    longitude TEXT,
    location TEXT,
    source_file TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rejected_records (
    rejected_id BIGSERIAL PRIMARY KEY,
    run_id BIGINT REFERENCES pipeline_run_log (run_id),
    unique_key TEXT,
    source_file TEXT,
    rejection_reason TEXT NOT NULL,
    raw_record JSONB,
    rejected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_bronze_311_unique_key
ON bronze_311_requests (unique_key);

CREATE INDEX IF NOT EXISTS idx_bronze_311_created_date
ON bronze_311_requests (created_date);

CREATE INDEX IF NOT EXISTS idx_rejected_records_run_id
ON rejected_records (run_id);

CREATE INDEX IF NOT EXISTS idx_pipeline_run_log_started_at
ON pipeline_run_log (run_started_at);
