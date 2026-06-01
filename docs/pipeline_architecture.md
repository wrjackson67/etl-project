# Pipeline Architecture

This project uses a medallion architecture to move NYC 311 data from raw CSV records into dashboard-ready reporting tables.

## Source Data

- Dataset: NYC 311 Service Requests, 2010-2019 export
- Working sample: 50,000 rows
- Local sample path: `data/raw/nyc_311_sample.csv`
- Raw data is ignored by Git to avoid pushing large files

## Bronze Layer

Table: `bronze_311_requests`

The bronze layer stores raw imported CSV records with minimal transformation. Date fields, coordinates, and IDs are loaded as text so the source values are preserved before cleaning.

Script:

```bash
python src/extract_load_raw.py --csv data/raw/nyc_311_sample.csv --truncate
```

## Silver Layer

Table: `silver_311_requests_clean`

The silver layer standardizes and validates records from bronze.

Main transformations:

- Parses created and closed dates into timestamps
- Creates `created_month`
- Standardizes borough values
- Standardizes status values
- Converts latitude and longitude into numeric fields
- Calculates `close_time_hours`
- Creates `open_flag`
- Flags duplicate request IDs
- Flags missing IDs, agency, complaint type, and borough
- Flags invalid close dates and invalid coordinates

SQL file:

```text
sql/02_clean_silver.sql
```

## Dimensional Model

Tables:

- `dim_agency`
- `dim_location`
- `dim_complaint`
- `fact_service_requests`

The fact table stores one row per service request and joins to dimensions through surrogate keys. This structure is designed for BI tools such as Power BI.

SQL files:

```text
sql/03_create_dimensions.sql
sql/04_create_fact_table.sql
```

## Gold Layer

Tables:

- `gold_monthly_borough_summary`
- `gold_agency_performance`
- `gold_complaint_trends`
- `gold_data_quality_report`

The gold layer contains dashboard-ready summaries for borough operations, agency performance, complaint trends, and data quality monitoring.

SQL file:

```text
sql/05_create_gold_tables.sql
```

## Orchestration

The full local pipeline can be run with:

```bash
python src/run_pipeline.py --csv data/raw/nyc_311_sample.csv
```

To rebuild downstream tables without reloading bronze:

```bash
python src/run_pipeline.py --skip-bronze
```
