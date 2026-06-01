NYC 311 Data Engineering Pipeline

Project Overview

This project is a portfolio scale data engineering pipeline for NYC 311 service request data. It loads raw data into PostgreSQL, cleans and validates the records, creates dimensional and reporting tables, and presents dashboard results in Power BI.

Business Problem

NYC 311 service request data is large, messy, and difficult to use directly for reporting. A city operations team benefits from a repeatable process that turns raw operational records into clean tables for agency performance, borough trends, complaint volume, closure time, and data quality.

Tools Used

Python, pandas, PostgreSQL, SQL, Power BI, Git, and GitHub.

Data Source

The project uses public NYC 311 service request data. The working sample contains 50,000 records from December 2019. The raw data file is stored locally and is not pushed to GitHub.

What Was Built

The bronze layer stores raw imported records.

The silver layer stores cleaned records with typed dates, standard borough values, standard status values, close time, open request flags, and data quality flags.

The dimensional layer stores agency, location, and complaint lookup tables plus one service request fact table.

The gold layer stores final reporting tables for monthly borough summaries, agency performance, complaint trends, and data quality reporting.

The validation script refreshes the data quality report.

The pipeline runner rebuilds the local pipeline in the correct order.

The Power BI dashboard provides executive overview and complaint analysis screenshots.

Repository Contents

The sql folder contains the database schema and transformations.

The src folder contains the Python ingestion, validation, and pipeline runner scripts.

The docs folder contains architecture notes, data dictionary, data quality summary, dashboard summary, and project summary.

The dashboard folder contains Power BI dashboard screenshots.

Project Results

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

Business Findings

The top complaint type is Noise Residential, with 6,528 requests.

The highest volume borough is Brooklyn, with 15,742 requests.

The top agency by request volume is the New York City Police Department, with 18,582 requests.

The highest average closure time belongs to the Department of Health and Mental Hygiene, at 12,070.94 hours.

Dashboard Summary

The dashboard includes an executive overview page and a complaint analysis page. The screenshots show request volume, open and closed requests, agency performance, borough volume, complaint volume, close time, and data quality metrics.

Future Improvements

A broader date range would make monthly trends and seasonal patterns more meaningful.

Additional dashboard pages could expand borough operations, agency performance, and data quality analysis.

Optional scheduling could be added after the local pipeline is complete.
