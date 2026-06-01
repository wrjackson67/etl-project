Project Summary

Current Pipeline Status

The project loads a 50,000 row NYC 311 sample into PostgreSQL, cleans it into a silver table, models it into dimensions and a service request fact table, creates dashboard ready gold reporting tables, and refreshes an automated data quality report.

Current implemented layers include bronze raw ingestion, silver cleaning, agency dimension, location dimension, complaint dimension, service request fact table, gold reporting tables, data quality validation, and an end to end pipeline runner.

Key Metrics

Bronze rows, 50,000.

Silver rows, 50,000.

Fact rows, 50,000.

Distinct request ids, 50,000.

Open requests, 1,190.

Average close time, 641.48 hours.

Data quality score, 98.67.

Records with data quality issues, 667.

Initial Findings

The top complaint type is Noise Residential, with 6,528 requests.

The highest volume borough is Brooklyn, with 15,742 requests.

The top agency by volume is the New York City Police Department, with 18,582 requests.

The highest average closure time belongs to the Department of Health and Mental Hygiene, at 12,070.94 hours.

The highest volume month in the sample is December 2019, with 50,000 requests.

The percent of records missing Closed Date is 1.67 percent.

The number of duplicate Unique Keys is 0.

The number of records with invalid close dates is 337.

The number of records with missing or unspecified borough is 330.

The complaint type with the largest month over month increase is not available in the current sample because the sample only contains December 2019 records.

Initial Recommendations

Review agencies with high average closure time separately because extreme outliers can distort operational averages.

Standardize borough handling before publishing monthly reporting.

Track open requests and invalid close dates in a recurring data quality report before dashboard refreshes.

Limitations

The current sample contains 50,000 records from December 2019 only, so seasonal trends and month over month complaint changes require a broader sample.

The full source export is too large for GitHub and is intentionally excluded from version control.

Power BI dashboard screenshots still need to be added after connecting to the gold tables.
