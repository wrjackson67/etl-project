Data Quality Rules

Unique Key must not be missing.

Unique Key should not be duplicated.

Created Date must not be missing.

Closed Date cannot be earlier than Created Date.

Borough must be standardized as Manhattan, Brooklyn, Queens, Bronx, Staten Island, or Unspecified.

Agency must not be missing.

Complaint Type must not be missing.

Latitude and Longitude should be valid when present.

Status must use a standard value.

Close Time Hours must not be negative.

Automated Validation Output

The validation script refreshes the data quality report from the cleaned silver table.

The report includes total records, duplicate id count, missing borough count, missing zip count, missing closed date count, invalid date count, records with quality issues, and data quality score.

Current Results

Total records, 50,000.

Duplicate id count, 0.

Missing borough count, 330.

Missing zip count, 1,092.

Missing closed date count, 833.

Invalid date count, 337.

Records with quality issues, 667.

Data quality score, 98.67.
