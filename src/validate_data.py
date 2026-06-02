"""Read data quality checks for the NYC 311 pipeline."""

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


def read_quality_report(connection) -> dict[str, object]:
    with connection.cursor() as cursor:
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
        results = read_quality_report(connection)
    finally:
        connection.close()

    print_summary(results)


if __name__ == "__main__":
    main()
