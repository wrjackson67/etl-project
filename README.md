NYC 311 Production-Style ELT Pipeline

Project Overview

This is a portfolio-scale data engineering project that turns NYC 311 service request data into tested, analytics-ready tables. It demonstrates the skeleton of a modern batch ELT platform: Python ingestion, PostgreSQL storage, dbt-owned bronze/silver/gold modeling, incremental loading, rejected-record handling, pipeline run logging, Airflow orchestration, Docker Compose, CI, and Power BI reporting.

Business Problem

NYC 311 service request data is large, messy, and difficult to report from directly. A city operations team needs a repeatable pipeline that can ingest new records, validate data quality, model dimensions and facts, and publish reporting marts for agency performance, borough trends, complaint volume, closure time, and pipeline health.

Modern Data Stack

- Python and pandas for CSV ingestion.
- PostgreSQL for local warehouse storage.
- dbt for silver, dimension, fact, and gold transformations plus automated tests.
- SQL scripts as a legacy fallback/reference path.
- Airflow for scheduled orchestration.
- Docker Compose for repeatable local setup.
- GitHub Actions for basic CI.
- Power BI for dashboard reporting.

Architecture

```text
NYC Open Data CSV
      |
      v
Python incremental loader
      |
      +--> pipeline_run_log
      +--> rejected_records
      |
      v
bronze_311_requests
      |
      v
dbt run
      |
      v
silver_311_requests_clean
      |
      v
dim_agency + dim_location + dim_complaint + fact_service_requests
      |
      v
gold reporting marts + dbt tests + Power BI
```

What Was Built

- Incremental ingestion that appends only new `unique_key` records by default.
- Full-refresh mode for rebuilding bronze from scratch.
- `pipeline_run_log` table with run status, start/end time, duration, row counts, rejected rows, last loaded request id, and failure messages.
- `rejected_records` table for missing request ids, duplicate rows within a chunk, and already-loaded incremental records.
- Bronze table that preserves raw source fields as text.
- dbt silver model that parses dates, standardizes borough and status values, converts coordinates, calculates close time, and flags data quality issues.
- dbt dimension and fact models for agency, location, complaint, and service request analysis.
- dbt gold marts for monthly borough summaries, agency performance, complaint trends, data quality, and pipeline observability.
- dbt tests for uniqueness, nulls, accepted values, relationships, and mart health.
- Airflow DAG that runs the Python pipeline and dbt tests on a daily schedule.
- Docker Compose stack for PostgreSQL, pipeline execution, and Airflow.
- GitHub Actions workflow for Python compilation and dbt project parsing.

Run Locally

1. Put the local CSV at `data/raw/nyc_311_sample.csv`.
2. Copy `.env.example` to `.env` and adjust database values if needed.
3. Start PostgreSQL:

```bash
docker compose up -d postgres
```

4. Run the pipeline:

```bash
docker compose run --rm pipeline
```

5. Run a full refresh when you want to rebuild bronze:

```bash
docker compose run --rm pipeline python src/run_pipeline.py --full-refresh
```

6. Run dbt tests:

```bash
DBT_PROFILES_DIR=dbt dbt test
```

The runner uses dbt by default. Use the legacy SQL fallback only when dbt is unavailable:

```bash
python src/run_pipeline.py --transform-engine sql
```

7. Start Airflow:

```bash
docker compose up airflow
```

The Airflow UI runs at `http://localhost:8080`.

Important Tables

- `bronze_311_requests`: raw ingested records.
- `silver_311_requests_clean`: cleaned and standardized records with quality flags.
- `dim_agency`, `dim_location`, `dim_complaint`: dimensional lookup tables.
- `fact_service_requests`: one row per accepted service request.
- `gold_monthly_borough_summary`: borough-level monthly reporting.
- `gold_agency_performance`: agency-level performance reporting.
- `gold_complaint_trends`: complaint trend reporting.
- `gold_data_quality_report`: automated data quality summary.
- `gold_pipeline_observability`: pipeline monitoring mart.
- `pipeline_run_log`: operational run history.
- `rejected_records`: records rejected during ingestion.

Current Sample Results

- Bronze rows: 50,000.
- Silver rows: 50,000.
- Fact rows: 50,000.
- Distinct request ids: 50,000.
- Open requests: 1,190.
- Average close time: 641.48 hours.
- Rows with data quality issues: 667.
- Invalid close dates: 337.
- Missing or unspecified boroughs: 330.
- Missing zip codes: 1,092.
- Missing closed dates: 833.
- Data quality score: 98.67.

Resume-Ready Summary

Built a production-style ELT pipeline using Python, Airflow, dbt, PostgreSQL, and Docker to ingest, validate, transform, and model NYC 311 service request data into analytics-ready fact and dimension tables. Implemented incremental loading, pipeline run logging, rejected-record handling, dbt-managed transformations, dbt data quality tests, and gold reporting marts for agency performance, borough trends, complaint volume, closure-time analysis, and pipeline observability.
