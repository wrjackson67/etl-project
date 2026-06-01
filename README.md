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
- Silver: cleaned and standardized records
- Gold: monthly summaries, agency performance, complaint trends, and data quality metrics

## Initial Deliverables

- Raw 311 sample dataset
- Python ingestion and validation scripts
- SQL schema and transformation files
- Data dictionary and quality rules
- Power BI dashboard screenshots
- Project summary with findings and recommendations

## Status

Project scaffold created. A 50,000-row working sample is expected at:

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
