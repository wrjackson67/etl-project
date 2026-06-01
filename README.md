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

Project scaffold created. Next step: download a manageable NYC 311 CSV sample and build the bronze load.
