# Project Summary

## Current Pipeline Status

The project loads a 50,000-row NYC 311 sample into PostgreSQL, cleans it into a silver table, models it into dimensions and a service request fact table, creates dashboard-ready gold reporting tables, and refreshes an automated data quality report.

Current implemented layers:

- Bronze raw ingestion
- Silver cleaning and validation flags
- Agency, location, and complaint dimensions
- Service request fact table
- Gold reporting tables
- Data quality validation script
- End-to-end pipeline runner

## Key Metrics

- Bronze rows: 50,000
- Silver rows: 50,000
- Fact rows: 50,000
- Distinct request IDs: 50,000
- Open requests: 1,190
- Average close time: 641.48 hours
- Data quality score: 98.67
- Records with data quality issues: 667

## Initial Findings

- Top complaint type: Noise - Residential, with 6,528 requests.
- Highest-volume borough: Brooklyn, with 15,742 requests.
- Top agency by volume: New York City Police Department, with 18,582 requests.
- Highest average closure time: Department of Health and Mental Hygiene, at 12,070.94 hours.
- Highest-volume month in the sample: December 2019, with 50,000 requests.
- Percent of records missing Closed Date: 1.67%.
- Duplicate Unique Keys: 0.
- Records with invalid close dates: 337.
- Records with missing or unspecified borough: 330.
- Complaint type with largest month-over-month increase: not available in the current sample because the sample only contains December 2019 records.

## Initial Recommendations

- Review agencies with high average closure time separately because extreme outliers can distort operational averages.
- Standardize borough handling before publishing monthly reporting.
- Track open requests and invalid close dates in a recurring data quality report before dashboard refreshes.

## Limitations

- The current sample contains 50,000 records from December 2019 only, so seasonal trends and month-over-month complaint changes require a broader sample.
- The full source export is too large for GitHub and is intentionally excluded from version control.
- Power BI dashboard screenshots still need to be added after connecting to the gold tables.
