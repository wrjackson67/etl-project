NYC 311 Data Engineering Pipeline

Project Overview

This project is a portfolio scale data engineering pipeline for NYC 311 service request data. It loads raw data into PostgreSQL, cleans and validates the records, creates reporting tables, and prepares the results for a Power BI dashboard.

Business Problem

NYC 311 service request data is large, messy, and difficult to use directly for reporting. A city operations team needs a repeatable process that turns raw records into clean tables for agency performance, borough trends, complaint volume, closure time, and data quality.

Tools Used

Python, pandas, PostgreSQL, SQL, Power BI, Git, and GitHub.

Data Source

The project uses public NYC 311 service request data. The working sample contains 50,000 records from December 2019. The raw data file is stored locally and is not pushed to GitHub.

Pipeline Architecture

The bronze layer stores raw imported records.

The silver layer stores cleaned records with typed dates, standard borough values, standard status values, close time, open request flags, and data quality flags.

The dimensional layer stores agency, location, and complaint lookup tables plus one service request fact table.

The gold layer stores final reporting tables for monthly borough summaries, agency performance, complaint trends, and data quality reporting.

How To Run The Project

Create a PostgreSQL database named nyc 311.

Copy the example environment file to a local environment file and add the database credentials.

Install the Python requirements.

Run the bronze load script to load the raw CSV sample.

Run the silver SQL script to clean the data.

Run the dimension and fact SQL scripts.

Run the gold SQL script.

Run the validation script.

The full pipeline runner can rebuild the full local pipeline with one command after the local environment is configured.

Current Validation Snapshot

Bronze rows, 50,000.

Silver rows, 50,000.

Fact rows, 50,000.

Distinct request ids, 50,000.

Open requests, 1,190.

Average close time, 641.48 hours.

Rows with data quality issues, 667.

Invalid close dates, 337.

Missing or unspecified boroughs, 330.

Missing zip codes, 1,092.

Missing closed dates, 833.

Data quality score, 98.67.

Initial Business Findings

The top complaint type is Noise Residential, with 6,528 requests.

The highest volume borough is Brooklyn, with 15,742 requests.

The top agency by request volume is the New York City Police Department, with 18,582 requests.

The highest average closure time belongs to the Department of Health and Mental Hygiene, at 12,070.94 hours.

Dashboard Summary

Power BI should connect to the gold reporting tables in PostgreSQL. The dashboard should include an executive overview, borough operations, agency performance, complaint trends, and data quality page. Screenshots should be saved in the dashboard screenshot folder.

Future Improvements

Load a broader date range so monthly trends and seasonal patterns are more meaningful.

Add dashboard screenshots after the Power BI report is built.

Add optional scheduling after the local pipeline is complete.
