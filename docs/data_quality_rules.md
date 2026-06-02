Data Quality Rules

Hard Reject Rules

These records are written to `rejected_records` during ingestion and do not enter bronze:

- Missing `unique_key`.
- Duplicate `unique_key` within the current ingestion chunk.
- `unique_key` already present in bronze during incremental runs.

Silver Quality Flags

These checks are retained as flags in `silver_311_requests_clean` so analysts can report on data quality without losing operational records:

- Request id is missing.
- Created date is missing or cannot be parsed.
- Closed date is earlier than created date.
- Agency is missing.
- Complaint type is missing.
- Borough is missing or standardized to `Unspecified`.
- Latitude is outside `-90` to `90` when present.
- Longitude is outside `-180` to `180` when present.
- Status is standardized to `Closed`, `Open`, or `Other`.
- Close time is only calculated when closed date is valid and not earlier than created date.

dbt Tests

The dbt project adds automated checks for:

- Unique and non-null request ids.
- Non-null created timestamps.
- Accepted borough values.
- Accepted status values.
- Referential integrity from fact rows to agency, location, and complaint dimensions.
- Non-null mart fields used by reports.
- Pipeline observability run ids and accepted status values.

Automated Validation Output

The dbt model `gold_data_quality_report` summarizes the cleaned silver table. The validation script reads that dbt-built table and prints total records, duplicate id count, missing borough count, missing zip count, missing closed date count, invalid date count, records with quality issues, and data quality score.

Current Results

- Total records: 50,000.
- Duplicate id count: 0.
- Missing borough count: 330.
- Missing zip count: 1,092.
- Missing closed date count: 833.
- Invalid date count: 337.
- Records with quality issues: 667.
- Data quality score: 98.67.
