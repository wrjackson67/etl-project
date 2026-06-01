# Data Quality Rules

- Unique Key must not be null.
- Unique Key should not be duplicated.
- Created Date must not be null.
- Closed Date cannot be earlier than Created Date.
- Borough must be standardized.
- Agency must not be null.
- Complaint Type must not be null.
- Latitude and Longitude should be valid if present.
- Status must use standardized values.
- Close Time Hours must not be negative.

## Automated Validation Output

The `src/validate_data.py` script refreshes `gold_data_quality_report` from the cleaned silver table and prints:

- Total records
- Duplicate ID count
- Missing borough count
- Missing zip count
- Missing closed date count
- Invalid date count
- Records with quality issues
- Data quality score
