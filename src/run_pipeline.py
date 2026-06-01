"""Orchestrate the local NYC 311 pipeline.

Usage:
    python src/run_pipeline.py --csv data/raw/nyc_311_sample.csv
"""

from __future__ import annotations

import argparse
import os
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

from extract_load_raw import DEFAULT_CSV_PATH, load_csv
from validate_data import build_connection_kwargs, refresh_quality_report


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SQL_STEPS = [
    PROJECT_ROOT / "sql" / "02_clean_silver.sql",
    PROJECT_ROOT / "sql" / "03_create_dimensions.sql",
    PROJECT_ROOT / "sql" / "04_create_fact_table.sql",
    PROJECT_ROOT / "sql" / "05_create_gold_tables.sql",
]


def execute_sql_file(connection, sql_path: Path) -> None:
    print(f"Running {sql_path.relative_to(PROJECT_ROOT)}")
    sql = sql_path.read_text(encoding="utf-8")
    with connection.cursor() as cursor:
        cursor.execute(sql)
    connection.commit()


def run_sql_steps() -> None:
    connection = psycopg2.connect(**build_connection_kwargs())
    try:
        for sql_path in SQL_STEPS:
            execute_sql_file(connection, sql_path)
    finally:
        connection.close()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run the full local NYC 311 pipeline.")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV_PATH, help="Path to the raw NYC 311 sample CSV.")
    parser.add_argument("--chunksize", type=int, default=10000, help="Rows to process per pandas chunk.")
    parser.add_argument("--skip-bronze", action="store_true", help="Skip raw CSV loading and rebuild downstream tables only.")
    parser.add_argument("--no-truncate", action="store_true", help="Do not truncate bronze before loading.")
    return parser.parse_args()


def main() -> None:
    load_dotenv(PROJECT_ROOT / ".env")
    args = parse_args()
    csv_path = args.csv if args.csv.is_absolute() else PROJECT_ROOT / args.csv

    if not args.skip_bronze:
        print("Running bronze load")
        total_rows = load_csv(csv_path, chunksize=args.chunksize, truncate=not args.no_truncate)
        print(f"Bronze load complete: {total_rows:,} rows")

    run_sql_steps()

    connection = psycopg2.connect(**build_connection_kwargs())
    try:
        results = refresh_quality_report(connection)
    finally:
        connection.close()

    print("Pipeline complete")
    print(f"Total Records: {results['total_records']}")
    print(f"Data Quality Score: {results['data_quality_score']}")
    print(f"Records With Quality Issues: {results['records_with_quality_issues']}")


if __name__ == "__main__":
    main()
