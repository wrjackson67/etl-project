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

## Status

Project scaffold created. Bronze ingestion, silver cleaning, dimensions, and the service request fact table are implemented. A 50,000-row working sample is expected at:

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
- Agencies in dimension: 15
- Locations in dimension: 400
- Complaint combinations in dimension: 1,115
- Fact rows: 50,000
- Unmatched fact rows: 0
