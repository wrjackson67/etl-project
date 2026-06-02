Project Summary

Current Pipeline Status

The project loads NYC 311 records into PostgreSQL, rejects unusable or duplicate incremental records, and uses dbt to clean accepted data into a silver table, model dimensions and a service request fact table, create dashboard-ready gold reporting tables, and validate the outputs with dbt tests.

Implemented capabilities include bronze raw ingestion, incremental loading, full-refresh mode, rejected-record handling, pipeline run logging, dbt silver cleaning, dbt agency/location/complaint dimensions, dbt service request facts, dbt gold reporting marts, data quality validation, Airflow orchestration, Docker Compose setup, GitHub Actions CI, and Power BI screenshots.

Key Metrics

- Bronze rows: 50,000.
- Silver rows: 50,000.
- Fact rows: 50,000.
- Distinct request ids: 50,000.
- Open requests: 1,190.
- Average close time: 641.48 hours.
- Data quality score: 98.67.
- Records with data quality issues: 667.

Initial Findings

- The top complaint type is Noise Residential, with 6,528 requests.
- The highest volume borough is Brooklyn, with 15,742 requests.
- The top agency by volume is the New York City Police Department, with 18,582 requests.
- The highest average closure time belongs to the Department of Health and Mental Hygiene, at 12,070.94 hours.
- The percent of records missing Closed Date is 1.67 percent.
- The number of duplicate Unique Keys is 0.
- The number of records with invalid close dates is 337.
- The number of records with missing or unspecified borough is 330.

Production-Style Features

- Incremental loader prevents repeat runs from duplicating records.
- `pipeline_run_log` captures status, timing, row counts, reject counts, failure messages, and last loaded request id.
- `rejected_records` stores hard rejects with reason codes and raw JSON payloads.
- dbt owns the transformation layer and tests uniqueness, nulls, accepted values, referential integrity, and mart health.
- Airflow DAG schedules the Python pipeline and dbt tests.
- Docker Compose gives the project a repeatable local runtime.
- CI compiles Python and parses the dbt project.

Limitations

The current dashboard results are based on a 50,000 row December 2019 sample, so seasonal trends and month-over-month changes require a broader sample.

The full source export is too large for GitHub and is intentionally excluded from version control.
