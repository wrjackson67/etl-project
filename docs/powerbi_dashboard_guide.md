# Power BI Dashboard Guide

## Data Connection

Connect Power BI Desktop to PostgreSQL:

- Server: `localhost`
- Database: `nyc_311`
- Data connectivity mode: Import

Load these tables:

- `gold_monthly_borough_summary`
- `gold_agency_performance`
- `gold_complaint_trends`
- `gold_data_quality_report`

Optional detail tables:

- `fact_service_requests`
- `dim_agency`
- `dim_location`
- `dim_complaint`

## Page 1: Executive Overview

Suggested visuals:

- KPI card: total service requests
- KPI card: closed requests
- KPI card: open requests
- KPI card: average close time
- Bar chart: top complaint types by request count
- Bar chart: top agencies by request count
- Column chart: request count by month

Recommended tables:

- `gold_complaint_trends`
- `gold_agency_performance`
- `gold_monthly_borough_summary`

## Page 2: Borough Operations

Suggested visuals:

- Bar chart: requests by borough
- Bar chart: average close time by borough
- Stacked bar chart: closed vs open requests by borough
- Table: borough, request count, closed count, open request count, percent closed

Recommended table:

- `gold_monthly_borough_summary`

## Page 3: Agency Performance

Suggested visuals:

- Bar chart: request volume by agency
- Bar chart: average close time by agency
- Bar chart: open request count by agency
- Table: agency, request count, closed count, percent closed, median close time

Recommended table:

- `gold_agency_performance`

## Page 4: Data Quality

Suggested visuals:

- KPI card: data quality score
- KPI card: records with quality issues
- KPI card: invalid date count
- KPI card: missing borough count
- KPI card: duplicate ID count
- Bar chart: missing zip, missing closed date, missing borough, invalid date counts

Recommended table:

- `gold_data_quality_report`

## Screenshot Checklist

Save dashboard screenshots in:

```text
dashboard/powerbi_screenshots/
```

Recommended filenames:

- `executive_overview.png`
- `borough_operations.png`
- `agency_performance.png`
- `data_quality.png`

## Notes

The current working sample contains December 2019 records only, so the dashboard should describe trend views as sample-limited until a broader date range is loaded.
