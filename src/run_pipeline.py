"""Orchestrate the local NYC 311 pipeline."""

from __future__ import annotations

import argparse
import shutil
import subprocess
import time
from pathlib import Path

import psycopg2
from dotenv import load_dotenv

from extract_load_raw import DEFAULT_CSV_PATH, load_csv
from validate_data import build_connection_kwargs, read_quality_report


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SQL_STEPS = [
    PROJECT_ROOT / "sql" / "02_clean_silver.sql",
    PROJECT_ROOT / "sql" / "03_create_dimensions.sql",
    PROJECT_ROOT / "sql" / "04_create_fact_table.sql",
    PROJECT_ROOT / "sql" / "05_create_gold_tables.sql",
]


def start_pipeline_run(source_file: str | None) -> int:
    connection = psycopg2.connect(**build_connection_kwargs())
    try:
        with connection.cursor() as cursor:
            cursor.execute((PROJECT_ROOT / "sql" / "01_create_tables.sql").read_text(encoding="utf-8"))
            cursor.execute(
                """
                INSERT INTO pipeline_run_log (source_file, status)
                VALUES (%s, 'running')
                RETURNING run_id;
                """,
                (source_file,),
            )
            run_id = cursor.fetchone()[0]
        connection.commit()
        return run_id
    finally:
        connection.close()


def finish_pipeline_run(
    run_id: int,
    status: str,
    duration_seconds: float,
    rows_extracted: int = 0,
    rows_loaded: int = 0,
    rows_rejected: int = 0,
    error_message: str | None = None,
) -> None:
    connection = psycopg2.connect(**build_connection_kwargs())
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE pipeline_run_log
                SET
                    status = %s,
                    run_finished_at = CURRENT_TIMESTAMP,
                    duration_seconds = %s,
                    rows_extracted = %s,
                    rows_loaded = %s,
                    rows_rejected = %s,
                    last_loaded_request_id = (
                        SELECT MAX(unique_key::BIGINT)::TEXT
                        FROM bronze_311_requests
                        WHERE unique_key ~ '^\d+$'
                    ),
                    error_message = %s
                WHERE run_id = %s;
                """,
                (
                    status,
                    round(duration_seconds, 2),
                    rows_extracted,
                    rows_loaded,
                    rows_rejected,
                    error_message,
                    run_id,
                ),
            )
        connection.commit()
    finally:
        connection.close()


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


def run_dbt_command(*args: str) -> None:
    dbt_path = shutil.which("dbt")
    if dbt_path is None:
        raise RuntimeError(
            "dbt is not installed. Run `pip install -r requirements.txt` or use "
            "`--transform-engine sql` for the legacy SQL fallback."
        )

    command = [dbt_path, *args, "--profiles-dir", "dbt"]
    print(f"Running {' '.join(command)}")
    subprocess.run(command, cwd=PROJECT_ROOT, check=True)


def run_dbt_steps(skip_tests: bool) -> None:
    run_dbt_command("run")
    if not skip_tests:
        run_dbt_command("test")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Local NYC 311 pipeline orchestration.")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV_PATH, help="Raw NYC 311 sample CSV path.")
    parser.add_argument("--chunksize", type=int, default=10000, help="Rows to process per pandas chunk.")
    parser.add_argument("--skip-bronze", action="store_true", help="Process downstream tables only.")
    parser.add_argument("--full-refresh", action="store_true", help="Truncate and reload bronze before downstream transforms.")
    parser.add_argument(
        "--transform-engine",
        choices=["dbt", "sql"],
        default="dbt",
        help="Use dbt models by default; choose sql for the legacy script fallback.",
    )
    parser.add_argument("--skip-dbt-tests", action="store_true", help="Run dbt models without dbt tests.")
    return parser.parse_args()


def main() -> None:
    load_dotenv(PROJECT_ROOT / ".env")
    args = parse_args()
    csv_path = args.csv if args.csv.is_absolute() else PROJECT_ROOT / args.csv
    run_id = start_pipeline_run(csv_path.name if not args.skip_bronze else None)
    started_at = time.monotonic()
    rows_extracted = 0
    rows_loaded = 0
    rows_rejected = 0

    try:
        if not args.skip_bronze:
            print("Running bronze load")
            load_result = load_csv(
                csv_path,
                chunksize=args.chunksize,
                truncate=args.full_refresh,
                incremental=not args.full_refresh,
                run_id=run_id,
            )
            rows_extracted = load_result.rows_extracted
            rows_loaded = load_result.rows_loaded
            rows_rejected = load_result.rows_rejected
            print(f"Bronze load complete: {rows_loaded:,} rows loaded")

        if args.transform_engine == "dbt":
            run_dbt_steps(skip_tests=args.skip_dbt_tests)
        else:
            run_sql_steps()

        connection = psycopg2.connect(**build_connection_kwargs())
        try:
            results = read_quality_report(connection)
        finally:
            connection.close()

        finish_pipeline_run(
            run_id=run_id,
            status="success",
            duration_seconds=time.monotonic() - started_at,
            rows_extracted=rows_extracted,
            rows_loaded=rows_loaded,
            rows_rejected=rows_rejected,
        )
    except Exception as exc:
        finish_pipeline_run(
            run_id=run_id,
            status="failed",
            duration_seconds=time.monotonic() - started_at,
            rows_extracted=rows_extracted,
            rows_loaded=rows_loaded,
            rows_rejected=rows_rejected,
            error_message=str(exc),
        )
        raise

    print("Pipeline complete")
    print(f"Total Records: {results['total_records']}")
    print(f"Data Quality Score: {results['data_quality_score']}")
    print(f"Records With Quality Issues: {results['records_with_quality_issues']}")


if __name__ == "__main__":
    main()
