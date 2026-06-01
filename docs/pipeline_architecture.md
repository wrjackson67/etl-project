Pipeline Architecture

This project uses a bronze, silver, and gold structure to turn raw NYC 311 records into reporting tables.

Source Data

The source data is public NYC 311 service request data. The working sample contains 50,000 records from December 2019. The raw file is stored locally and is excluded from GitHub because large data files do not belong in the repository.

Bronze Layer

The bronze layer stores raw imported records. It keeps the source values close to their original form. Dates, coordinates, and ids are loaded as text so the raw data is preserved before cleaning.

Silver Layer

The silver layer cleans and standardizes the bronze data.

The silver process parses created and closed dates, creates a reporting month, standardizes borough names, standardizes status values, converts coordinates, calculates close time, creates an open request flag, and creates data quality flags.

Dimensional Model

The model includes an agency table, a location table, a complaint table, and a service request fact table.

The fact table stores one row per service request. It links to the dimension tables through generated keys. This structure is ready for Power BI reporting.

Gold Layer

The gold layer contains reporting tables for monthly borough summaries, agency performance, complaint trends, and data quality reporting.

These tables are the main tables for the Power BI dashboard.

Orchestration

The pipeline runner can rebuild the local pipeline in order. It loads bronze data, rebuilds silver, rebuilds dimensions and fact, rebuilds gold, and refreshes the validation report.

Current Output

The current pipeline produces 50,000 fact rows, 15 agencies, 400 locations, 1,115 complaint combinations, and a data quality score of 98.67.
