# NYC 311 Data Engineering Pipeline

Portfolio-scale data engineering project for NYC 311 operations analytics using a bronze/silver/gold workflow.

## Project Overview

This project will ingest raw NYC 311 service request data, load it into PostgreSQL, clean and validate it, model it into analytics-ready tables, and support Power BI dashboard reporting.

## Planned Stack

- Python
- pandas
- PostgreSQL
- SQL
- Power BI

## Pipeline Architecture

- Bronze: raw imported 311 records
- Silver: cleaned and standardized records with typed dates, close-time metrics, normalized borough/status values, duplicate flags, and data quality issue flags
- Gold: monthly summaries, agency performance, complaint trends, and data quality metrics

## Initial Deliverables

- Raw 311 sample dataset
- Python ingestion and validation scripts
- SQL schema and transformation files
- Data dictionary and quality rules
- Power BI dashboard screenshots
- Project summary with findings and recommendations
- Power BI dashboard build guide

## Status

Project scaffold created. Bronze ingestion, silver cleaning, dimensions, fact table, and gold reporting tables are implemented. A 50,000-row working sample is expected at:

```text
data/raw/nyc_311_sample.csv
```

The raw sample is ignored by Git so large data files do not get pushed.

## How to Run the Bronze Load

1. Create a PostgreSQL database named `nyc_311`.
2. Copy `.env.example` to `.env` and update the database credentials.
3. Install Python dependencies:

```bash
pip install -r requirements.txt
```

4. Load the CSV into the bronze table:

```bash
python src/extract_load_raw.py --csv data/raw/nyc_311_sample.csv --truncate
```

5. Build the cleaned silver table:

```bash
psql -h localhost -p 5432 -U postgres -d nyc_311 -f sql/02_clean_silver.sql
```

6. Build dimensions and fact table:

```bash
psql -h localhost -p 5432 -U postgres -d nyc_311 -f sql/03_create_dimensions.sql
psql -h localhost -p 5432 -U postgres -d nyc_311 -f sql/04_create_fact_table.sql
```

7. Build gold reporting tables:

```bash
psql -h localhost -p 5432 -U postgres -d nyc_311 -f sql/05_create_gold_tables.sql
```

8. Refresh the data quality report:

```bash
python src/validate_data.py
```

Or run the full pipeline with one command:

```bash
python src/run_pipeline.py --csv data/raw/nyc_311_sample.csv
```

To rebuild silver, dimensions, fact, gold, and validation without reloading the CSV:

```bash
python src/run_pipeline.py --skip-bronze
```

## Current Validation Snapshot

The initial 50,000-row sample produced:

- Bronze rows: 50,000
- Silver rows: 50,000
- Distinct request IDs: 50,000
- Open requests: 1,190
- Average close time: 641.48 hours
- Rows with data quality issues: 667
- Invalid close dates: 337
- Missing/unspecified boroughs: 330
- Missing zip codes: 1,092
- Missing closed dates: 833
- Agencies in dimension: 15
- Locations in dimension: 400
- Complaint combinations in dimension: 1,115
- Fact rows: 50,000
- Unmatched fact rows: 0
- Monthly borough summary rows: 6
- Agency performance rows: 15
- Complaint trend rows: 150
- Data quality score: 98.67

## Initial Business Findings

- Top complaint type: Noise - Residential, with 6,528 requests
- Highest-volume borough: Brooklyn, with 15,742 requests
- Highest average closure time: Department of Health and Mental Hygiene, at 12,070.94 hours
- Records with missing/unspecified borough: 330
- Records with invalid close dates: 337

## Dashboard

Power BI should connect to the PostgreSQL `gold_*` tables. The dashboard build guide is available at:

```text
docs/powerbi_dashboard_guide.md
```

Export dashboard screenshots into:

```text
dashboard/powerbi_screenshots/
```
