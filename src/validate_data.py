"""Refresh data quality checks for the NYC 311 pipeline."""

from __future__ import annotations

import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv


PROJECT_ROOT = Path(__file__).resolve().parents[1]


def build_connection_kwargs() -> dict[str, str]:
    return {
        "host": os.getenv("POSTGRES_HOST", "localhost"),
        "port": os.getenv("POSTGRES_PORT", "5432"),
        "dbname": os.getenv("POSTGRES_DB", "nyc_311"),
        "user": os.getenv("POSTGRES_USER", "postgres"),
        "password": os.getenv("POSTGRES_PASSWORD", "postgres"),
    }


def refresh_quality_report(connection) -> dict[str, object]:
    sql = """
        DROP TABLE IF EXISTS gold_data_quality_report;

        CREATE TABLE gold_data_quality_report AS
        SELECT
            CURRENT_DATE AS run_date,
            COUNT(*) AS total_records,
            COUNT(*) - COUNT(DISTINCT request_id) AS duplicate_id_count,
            SUM(missing_request_id_flag::INT) AS missing_request_id_count,
            SUM(invalid_created_date_flag::INT) AS invalid_created_date_count,
            SUM(invalid_close_date_flag::INT) AS invalid_date_count,
            SUM(missing_agency_flag::INT) AS missing_agency_count,
            SUM(missing_complaint_type_flag::INT) AS missing_complaint_type_count,
            SUM(missing_or_unspecified_borough_flag::INT) AS missing_borough_count,
            SUM(CASE WHEN incident_zip IS NULL THEN 1 ELSE 0 END) AS missing_zip_count,
            SUM(CASE WHEN closed_at IS NULL THEN 1 ELSE 0 END) AS missing_closed_date_count,
            SUM(invalid_latitude_flag::INT) AS invalid_latitude_count,
            SUM(invalid_longitude_flag::INT) AS invalid_longitude_count,
            SUM(has_data_quality_issue::INT) AS records_with_quality_issues,
            ROUND(
                (1 - (SUM(has_data_quality_issue::INT)::NUMERIC / NULLIF(COUNT(*), 0))) * 100,
                2
            ) AS data_quality_score
        FROM silver_311_requests_clean;
    """

    with connection.cursor() as cursor:
        cursor.execute(sql)
        cursor.execute(
            """
            SELECT
                total_records,
                duplicate_id_count,
                missing_borough_count,
                missing_zip_count,
                missing_closed_date_count,
                invalid_date_count,
                records_with_quality_issues,
                data_quality_score
            FROM gold_data_quality_report;
            """
        )
        columns = [description[0] for description in cursor.description]
        values = cursor.fetchone()

    connection.commit()
    return dict(zip(columns, values))


def print_summary(results: dict[str, object]) -> None:
    print("Data quality validation complete")
    for key, value in results.items():
        label = key.replace("_", " ").title()
        print(f"{label}: {value}")


def main() -> None:
    load_dotenv(PROJECT_ROOT / ".env")
    connection = psycopg2.connect(**build_connection_kwargs())
    try:
        results = refresh_quality_report(connection)
    finally:
        connection.close()

    print_summary(results)


if __name__ == "__main__":
    main()
