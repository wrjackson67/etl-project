# Project Summary

## Current Pipeline Status

The project currently loads a 50,000-row NYC 311 sample into PostgreSQL, cleans it into a silver table, models it into dimensions and a service request fact table, and creates dashboard-ready gold reporting tables.

## Initial Findings

- Top complaint type: Noise - Residential, with 6,528 requests.
- Highest-volume borough: Brooklyn, with 15,742 requests.
- Highest average closure time: Department of Health and Mental Hygiene, at 12,070.94 hours.
- Data quality score: 98.67.
- Records with data quality issues: 667.
- Records with invalid close dates: 337.
- Records with missing or unspecified borough: 330.

## Initial Recommendations

- Review agencies with high average closure time separately because extreme outliers can distort operational averages.
- Standardize borough handling before publishing monthly reporting.
- Track open requests and invalid close dates in a recurring data quality report before dashboard refreshes.
