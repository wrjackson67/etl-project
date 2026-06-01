Data Dictionary

This document explains the main final fields used by the reporting tables.

Service Request Fact Table

Request id comes from Unique Key. It identifies each NYC 311 service request. It is required and should be unique. Example value, 45285347.

Created at comes from Created Date. It is the timestamp when the request was created. It is required and must be a valid date and time.

Closed at comes from Closed Date. It is the timestamp when the request was closed. It is optional because open requests may not have a close date. It cannot be earlier than the created date.

Created month comes from Created Date. It is the month used for reporting. Example value, December 2019.

Agency id links each request to the agency table. It is required for reporting.

Location id links each request to the location table. It is required for reporting.

Complaint id links each request to the complaint table. It is required for reporting.

Status comes from Status. It is standardized as Closed, Open, or Other.

Close time hours comes from Created Date and Closed Date. It measures how many hours passed between creation and closure. It is optional because open requests may not have a close date.

Open flag comes from Status. It shows whether a request is open or closed. A value of 1 means open. A value of 0 means closed.

Has data quality issue comes from validation rules. It shows whether the record failed a major quality check.

Agency Table

Agency id is a generated key for agency records.

Agency comes from Agency. It stores the short agency code. Example value, NYPD.

Agency name comes from Agency Name. It stores the full agency name. Example value, New York City Police Department.

Location Table

Location id is a generated key for location records.

Borough comes from Borough. It is standardized as Manhattan, Brooklyn, Queens, Bronx, Staten Island, or Unspecified.

Incident zip comes from Incident Zip. It stores the request zip code when present.

City comes from City. It stores the city value after standard formatting.

Complaint Table

Complaint id is a generated key for complaint records.

Complaint type comes from Problem formerly Complaint Type. It stores the main complaint category. Example value, Noise Residential.

Descriptor comes from Problem Detail formerly Descriptor. It stores the more specific complaint detail.

Location type comes from Location Type. It stores the type of place tied to the complaint.

Gold Reporting Tables

The monthly borough summary table tracks request count, closed count, open count, average close time, median close time, and percent closed by month and borough.

The agency performance table tracks request count, closed count, open count, average close time, median close time, and percent closed by agency.

The complaint trends table tracks request count and close time by month and complaint type.

The data quality report table tracks duplicate ids, missing fields, invalid dates, records with quality issues, and the data quality score.
