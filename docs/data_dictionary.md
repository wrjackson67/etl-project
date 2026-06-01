# Data Dictionary

This dictionary documents the main final fields used in the dimensional and gold reporting layers.

## fact_service_requests

| Field name | Source field | Definition | Data type | Required | Validation rule | Example |
|---|---|---|---|---|---|---|
| request_id | Unique Key | NYC 311 service request identifier | text | yes | Must not be null; should be unique | 45285347 |
| created_at | Created Date | Timestamp when the request was created | timestamp | yes | Must parse into a valid timestamp | 2019-12-31 12:59:54 |
| closed_at | Closed Date | Timestamp when the request was closed | timestamp | no | Cannot be earlier than created_at | 2020-01-01 10:15:00 |
| created_month | Created Date | First day of the request creation month | date | yes | Derived from created_at | 2019-12-01 |
| agency_id | Agency, Agency Name | Foreign key to dim_agency | integer | yes | Must match dim_agency | 1 |
| location_id | Borough, Incident Zip, City | Foreign key to dim_location | integer | yes | Must match dim_location | 42 |
| complaint_id | Complaint Type, Descriptor, Location Type | Foreign key to dim_complaint | integer | yes | Must match dim_complaint | 105 |
| status | Status | Standardized request status | text | yes | Must be Closed, Open, or Other | Closed |
| close_time_hours | Created Date, Closed Date | Hours between request creation and closure | numeric | no | Must be greater than or equal to 0 | 42.50 |
| open_flag | Status | Indicates whether the request is still open | integer | yes | 1 for open, 0 for closed | 0 |
| has_data_quality_issue | Validation flags | Indicates whether the record failed any major quality rule | boolean | yes | True when any major issue flag is true | false |

## dim_agency

| Field name | Source field | Definition | Data type | Required | Validation rule | Example |
|---|---|---|---|---|---|---|
| agency_id | Generated | Surrogate key for agency records | integer | yes | Primary key | 1 |
| agency | Agency | Agency code | text | yes | Missing values are set to Unknown | NYPD |
| agency_name | Agency Name | Full agency name | text | yes | Missing values are set to Unknown | New York City Police Department |

## dim_location

| Field name | Source field | Definition | Data type | Required | Validation rule | Example |
|---|---|---|---|---|---|---|
| location_id | Generated | Surrogate key for location records | integer | yes | Primary key | 42 |
| borough | Borough | Standardized borough name | text | yes | Must be Manhattan, Brooklyn, Queens, Bronx, Staten Island, or Unspecified | Brooklyn |
| incident_zip | Incident Zip | ZIP code for the service request | text | no | Missing values are set to Unknown in the dimension | 11201 |
| city | City | Standardized city value | text | no | Missing values are set to Unknown in the dimension | Brooklyn |

## dim_complaint

| Field name | Source field | Definition | Data type | Required | Validation rule | Example |
|---|---|---|---|---|---|---|
| complaint_id | Generated | Surrogate key for complaint records | integer | yes | Primary key | 105 |
| complaint_type | Problem (formerly Complaint Type) | Main complaint category | text | yes | Missing values are set to Unknown | Noise - Residential |
| descriptor | Problem Detail (formerly Descriptor) | More specific complaint detail | text | no | Missing values are set to Unknown | Loud Music/Party |
| location_type | Location Type | Type of location associated with complaint | text | no | Missing values are set to Unknown | Residential Building/House |

## Gold Reporting Tables

| Table | Grain | Purpose |
|---|---|---|
| gold_monthly_borough_summary | One row per month and borough | Tracks request volume, closure counts, open backlog, average/median close time, and percent closed |
| gold_agency_performance | One row per agency | Tracks agency volume, closure rate, backlog, and close-time performance |
| gold_complaint_trends | One row per month and complaint type | Tracks complaint volume, close time, and month-over-month request changes |
| gold_data_quality_report | One row per validation run | Tracks missing fields, duplicate IDs, invalid dates, quality issue count, and quality score |
