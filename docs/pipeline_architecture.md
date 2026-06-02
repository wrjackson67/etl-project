Pipeline Architecture

This project uses a production-style batch ELT design for NYC 311 service request data.

Flow

```text
Source CSV
  -> Python incremental ingestion
  -> bronze_311_requests
  -> dbt run
  -> silver_311_requests_clean
  -> dbt dimensions and fact table
  -> dbt gold reporting marts
  -> dbt tests and Power BI reporting
```

Operational Metadata

Each run writes to `pipeline_run_log`. The table tracks run status, source file, start and finish timestamps, duration, extracted rows, loaded rows, rejected rows, last loaded request id, and failure messages.

Records that should not enter bronze are written to `rejected_records`. Current hard-reject reasons include missing request ids, duplicate ids in the current chunk, and records already loaded during incremental runs.

Incremental Loading

The default pipeline mode appends only records with request ids that are not already present in bronze. This keeps repeat runs from duplicating data. `--full-refresh` truncates bronze and rebuilds the warehouse from the source file.

Orchestration

`src/run_pipeline.py` executes the local pipeline in order:

1. Create operational and bronze tables.
2. Start a pipeline run log entry.
3. Incrementally load bronze records.
4. Run dbt models to rebuild silver, dimensions, fact, and gold marts.
5. Run dbt tests unless skipped.
6. Mark the run as success or failed.

The Airflow DAG in `dags/nyc_311_batch_elt.py` schedules the Python pipeline and dbt tests.

Modeling Layers

The bronze layer preserves raw source fields as text.

The dbt silver model standardizes dates, boroughs, statuses, coordinates, close-time metrics, open flags, duplicate indicators, and quality flags.

The dimensional layer contains agency, location, and complaint dimensions plus a service request fact table.

The gold layer contains reporting tables for borough trends, agency performance, complaint trends, data quality, and pipeline observability.

Testing

dbt tests validate key expectations: unique request ids, non-null created dates, accepted borough and status values, dimension relationship integrity, and mart health.
