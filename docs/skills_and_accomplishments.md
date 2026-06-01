Skills And Accomplishments Summary

Project Purpose

This project was built to demonstrate an end to end data engineering workflow using public NYC 311 service request data. The goal was to move beyond simple spreadsheet analysis and build a repeatable pipeline that ingests raw operational data, stores it in PostgreSQL, cleans and validates it, models it into reporting tables, and supports business intelligence reporting in Power BI.

The project shows practical experience with data ingestion, SQL transformation, data quality validation, dimensional modeling, reporting table design, pipeline orchestration, documentation, and dashboard communication.

Core Technical Skills Demonstrated

Python Data Engineering

The project uses Python to load a raw NYC 311 CSV sample into PostgreSQL. The ingestion script reads the data in chunks so the load process can handle larger files without requiring the entire file to fit in memory at once.

This demonstrates practical Python skills for file handling, data loading, environment configuration, database connection management, and repeatable local pipeline execution.

PostgreSQL And SQL Development

The project uses PostgreSQL as the main database. SQL scripts create the bronze, silver, dimensional, fact, and gold reporting layers.

This demonstrates the ability to design database tables, write transformation SQL, convert raw text fields into typed values, create indexes, use joins, aggregate data, calculate metrics, and prepare clean tables for dashboard users.

Medallion Architecture

The project follows a bronze, silver, and gold structure.

The bronze layer preserves raw imported records.

The silver layer standardizes and validates records.

The dimensional and fact layer creates a reporting model.

The gold layer creates final dashboard ready summary tables.

This demonstrates understanding of layered data architecture and how raw operational data can be organized into cleaner, more useful analytics outputs.

Data Cleaning And Standardization

The silver layer converts created and closed date fields into timestamps, creates a reporting month, standardizes borough values, standardizes status values, converts coordinates, calculates close time in hours, and creates open request flags.

This demonstrates the ability to turn messy operational fields into consistent reporting fields that business users can trust.

Data Quality Validation

The project includes automated data quality checks for duplicate request ids, missing request ids, invalid created dates, invalid close dates, missing agencies, missing complaint types, missing boroughs, missing zip codes, missing closed dates, invalid latitude values, and invalid longitude values.

The final data quality score for the current sample is 98.67.

This demonstrates the ability to think beyond loading data and include checks that protect reporting accuracy.

Dimensional Modeling

The project creates an agency dimension, location dimension, complaint dimension, and service request fact table.

The fact table stores one row per service request and connects to the dimensions through generated keys.

This demonstrates basic star schema design and an understanding of how analytical models should be structured for business intelligence tools.

Gold Reporting Tables

The gold layer creates reporting tables for monthly borough summaries, agency performance, complaint trends, and data quality reporting.

These tables are designed for direct use in Power BI and reduce the amount of modeling needed inside the dashboard tool.

This demonstrates the ability to prepare curated reporting outputs instead of expecting dashboard users to query raw data.

Pipeline Orchestration

The project includes a local pipeline runner that rebuilds the pipeline in order. It can load bronze data, rebuild silver data, rebuild dimensions and fact tables, rebuild gold reporting tables, and refresh the validation report.

This demonstrates an understanding of pipeline order, repeatability, and automation.

Business Intelligence And Dashboarding

The project includes Power BI dashboard screenshots for executive overview and complaint analysis.

The dashboard communicates request volume, closure performance, agency workload, borough distribution, complaint volume, close time, and data quality metrics.

This demonstrates the ability to connect backend data engineering work to a visible business intelligence deliverable.

What Was Accomplished

The project successfully loaded 50,000 NYC 311 records into PostgreSQL.

The project created a bronze table that preserves raw imported records.

The project created a silver table that cleans and standardizes raw records.

The project created data quality flags for missing fields, invalid dates, duplicate ids, and coordinate issues.

The project created an agency dimension with 15 agencies.

The project created a location dimension with 400 location combinations.

The project created a complaint dimension with 1,115 complaint combinations.

The project created a service request fact table with 50,000 rows.

The project created gold reporting tables for borough summaries, agency performance, complaint trends, and data quality.

The project created an automated data quality report with a score of 98.67.

The project created Power BI screenshots that show the final reporting output.

The project created professional documentation that explains the architecture, fields, quality rules, dashboard output, and project results.

Business Findings From The Sample

The top complaint type is Noise Residential, with 6,528 requests.

The highest volume borough is Brooklyn, with 15,742 requests.

The top agency by request volume is the New York City Police Department, with 18,582 requests.

The highest average closure time belongs to the Department of Health and Mental Hygiene, at 12,070.94 hours.

The sample includes 1,190 open requests.

The average close time is 641.48 hours.

The sample contains 337 invalid close dates.

The sample contains 330 missing or unspecified borough values.

The sample contains 1,092 missing zip codes.

The sample contains 833 missing closed dates.

Power BI Image Insight

Executive Overview Image

The executive overview screenshot shows high level operational metrics for the current NYC 311 sample.

The top cards show total requests, closed requests, open requests, median agency close time, and closure rate. This gives a reviewer a fast understanding of request volume and operational status.

The requests by agency visual shows which agencies handled the largest number of requests. The New York City Police Department has the highest request volume in the sample, followed by the Department of Sanitation and the Department of Housing Preservation and Development.

The median close time by agency visual shows that some agencies have much longer closure times than others. This highlights why median and average close time should be monitored carefully, because closure time can vary widely across agencies.

The requests by borough visual shows how requests are distributed geographically. Brooklyn has the largest share of requests in the sample, followed by Queens, Bronx, Manhattan, and Staten Island.

The data quality summary gives a dashboard level view of total records, duplicate ids, missing borough values, missing zip values, missing closed dates, and invalid dates. This connects the dashboard back to the validation work in the pipeline.

Complaint Analysis Image

The complaint analysis screenshot focuses on complaint volume and closure time by complaint type.

The top cards show median close time, complaint type count, total requests, and largest complaint volume. This gives a quick summary of the complaint landscape.

The slowest complaint types by median close time visual identifies complaint categories that may require longer operational follow up. Examples shown include Adopt A Basket, Window Guard, Mobile Food Vendor, Smoking, and Non Residential Heat.

The top complaint types by request volume visual shows which complaint categories drive the most work. Noise Residential is the largest complaint type in the sample, followed by HEAT HOT WATER, Request Large Bulky Item Collection, Illegal Parking, and Blocked Driveway.

Together, the two dashboard pages show both operational scale and operational friction. The executive overview answers what is happening overall. The complaint analysis page answers which complaint types are driving volume and which ones are slowest to close.

Resume Ready Themes

This project can support resume bullets about building an end to end data engineering pipeline with Python, SQL, PostgreSQL, and Power BI.

It can support bullets about designing bronze, silver, and gold data layers for operational analytics.

It can support bullets about creating data quality checks for duplicates, missing fields, invalid dates, and reporting readiness.

It can support bullets about creating dimensional models and dashboard ready reporting tables.

It can support bullets about delivering Power BI reporting for agency performance, borough trends, complaint analysis, closure time, and data quality.

LinkedIn Project Positioning

This project can be described as a public data engineering portfolio project using NYC 311 data.

The strongest positioning is that the project demonstrates the full path from raw operational data to dashboard ready analytics.

The project is useful for roles such as Data Engineer, Junior Data Engineer, ETL Analyst, SQL Developer, Data Analyst, BI Analyst, Reporting Analyst, and Operations Analytics Analyst.

Main Takeaway

This project demonstrates that raw public data can be transformed into a clean, validated, modeled, and dashboard ready analytics product. It shows practical skills across Python, SQL, PostgreSQL, data quality, data modeling, reporting tables, documentation, and Power BI.
