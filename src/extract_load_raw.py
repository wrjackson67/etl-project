"""Load raw NYC 311 CSV data into the bronze table."""

from __future__ import annotations

import argparse
import os
from dataclasses import dataclass
from io import StringIO
from pathlib import Path

import pandas as pd
import psycopg2
from psycopg2.extras import Json, execute_values
from dotenv import load_dotenv


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV_PATH = PROJECT_ROOT / "data" / "raw" / "nyc_311_sample.csv"
CREATE_TABLE_SQL = PROJECT_ROOT / "sql" / "01_create_tables.sql"


COLUMN_RENAMES = {
    "Unique Key": "unique_key",
    "Created Date": "created_date",
    "Closed Date": "closed_date",
    "Agency": "agency",
    "Agency Name": "agency_name",
    "Problem (formerly Complaint Type)": "complaint_type",
    "Problem Detail (formerly Descriptor)": "descriptor",
    "Additional Details": "additional_details",
    "Location Type": "location_type",
    "Incident Zip": "incident_zip",
    "Incident Address": "incident_address",
    "Street Name": "street_name",
    "Cross Street 1": "cross_street_1",
    "Cross Street 2": "cross_street_2",
    "Intersection Street 1": "intersection_street_1",
    "Intersection Street 2": "intersection_street_2",
    "Address Type": "address_type",
    "City": "city",
    "Landmark": "landmark",
    "Facility Type": "facility_type",
    "Status": "status",
    "Due Date": "due_date",
    "Resolution Description": "resolution_description",
    "Resolution Action Updated Date": "resolution_action_updated_date",
    "Community Board": "community_board",
    "Council District": "council_district",
    "Police Precinct": "police_precinct",
    "BBL": "bbl",
    "Borough": "borough",
    "X Coordinate (State Plane)": "x_coordinate_state_plane",
    "Y Coordinate (State Plane)": "y_coordinate_state_plane",
    "Open Data Channel Type": "open_data_channel_type",
    "Park Facility Name": "park_facility_name",
    "Park Borough": "park_borough",
    "Vehicle Type": "vehicle_type",
    "Taxi Company Borough": "taxi_company_borough",
    "Taxi Pick Up Location": "taxi_pick_up_location",
    "Bridge Highway Name": "bridge_highway_name",
    "Bridge Highway Direction": "bridge_highway_direction",
    "Road Ramp": "road_ramp",
    "Bridge Highway Segment": "bridge_highway_segment",
    "Latitude": "latitude",
    "Longitude": "longitude",
    "Location": "location",
}


@dataclass
class LoadResult:
    rows_extracted: int = 0
    rows_loaded: int = 0
    rows_rejected: int = 0


def build_connection_kwargs() -> dict[str, str]:
    return {
        "host": os.getenv("POSTGRES_HOST", "localhost"),
        "port": os.getenv("POSTGRES_PORT", "5432"),
        "dbname": os.getenv("POSTGRES_DB", "nyc_311"),
        "user": os.getenv("POSTGRES_USER", "postgres"),
        "password": os.getenv("POSTGRES_PASSWORD", "postgres"),
    }


def create_tables(connection) -> None:
    sql = CREATE_TABLE_SQL.read_text(encoding="utf-8")
    with connection.cursor() as cursor:
        cursor.execute(sql)
    connection.commit()


def get_existing_request_ids(connection, request_ids: list[str]) -> set[str]:
    if not request_ids:
        return set()

    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT unique_key
            FROM bronze_311_requests
            WHERE unique_key = ANY(%s);
            """,
            (request_ids,),
        )
        return {row[0] for row in cursor.fetchall()}


def get_last_loaded_request_id(connection) -> str | None:
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT MAX(unique_key::BIGINT)::TEXT
            FROM bronze_311_requests
            WHERE unique_key ~ '^\d+$';
            """
        )
        row = cursor.fetchone()
    return row[0] if row else None


def split_rejected_records(
    connection,
    chunk: pd.DataFrame,
    source_file: str,
    run_id: int | None,
    incremental: bool,
) -> tuple[pd.DataFrame, list[tuple]]:
    normalized = chunk.where(pd.notna(chunk), None)
    missing_key_mask = normalized["unique_key"].isna() | (normalized["unique_key"].astype(str).str.strip() == "")
    duplicate_in_file_mask = normalized["unique_key"].duplicated(keep="first") & ~missing_key_mask

    existing_key_mask = pd.Series(False, index=normalized.index)
    if incremental:
        request_ids = normalized.loc[~missing_key_mask, "unique_key"].astype(str).tolist()
        existing_request_ids = get_existing_request_ids(connection, request_ids)
        existing_key_mask = normalized["unique_key"].astype(str).isin(existing_request_ids)

    reject_mask = missing_key_mask | duplicate_in_file_mask | existing_key_mask
    rejected_rows = []

    for index, row in normalized.loc[reject_mask].iterrows():
        reasons = []
        if missing_key_mask.loc[index]:
            reasons.append("missing_request_id")
        if duplicate_in_file_mask.loc[index]:
            reasons.append("duplicate_in_source_chunk")
        if existing_key_mask.loc[index]:
            reasons.append("already_loaded_incremental_record")

        raw_record = {key: value for key, value in row.to_dict().items() if value is not None}
        rejected_rows.append(
            (
                run_id,
                row.get("unique_key"),
                source_file,
                ",".join(reasons),
                Json(raw_record),
            )
        )

    accepted = normalized.loc[~reject_mask].copy()
    return accepted, rejected_rows


def insert_rejected_records(connection, rejected_rows: list[tuple]) -> None:
    if not rejected_rows:
        return

    with connection.cursor() as cursor:
        execute_values(
            cursor,
            """
            INSERT INTO rejected_records (
                run_id,
                unique_key,
                source_file,
                rejection_reason,
                raw_record
            )
            VALUES %s;
            """,
            rejected_rows,
        )
    connection.commit()


def copy_chunk(connection, chunk: pd.DataFrame, table_name: str) -> None:
    if chunk.empty:
        return

    buffer = StringIO()
    chunk.to_csv(buffer, index=False, header=False, na_rep="")
    buffer.seek(0)

    columns = ", ".join(chunk.columns)
    copy_sql = f"""
        COPY {table_name} ({columns})
        FROM STDIN WITH (FORMAT CSV, NULL '', QUOTE '"', ESCAPE '"')
    """

    with connection.cursor() as cursor:
        cursor.copy_expert(copy_sql, buffer)
    connection.commit()


def load_csv(
    csv_path: Path,
    chunksize: int,
    truncate: bool = False,
    incremental: bool = True,
    run_id: int | None = None,
) -> LoadResult:
    connection = psycopg2.connect(**build_connection_kwargs())
    create_tables(connection)

    if truncate:
        with connection.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE bronze_311_requests;")
        connection.commit()
        incremental = False

    result = LoadResult()
    last_loaded_request_id = get_last_loaded_request_id(connection) if incremental else None
    if last_loaded_request_id:
        print(f"Incremental load starting after request id {last_loaded_request_id}")

    try:
        for chunk in pd.read_csv(csv_path, chunksize=chunksize, dtype=str, low_memory=False):
            chunk = chunk.rename(columns=COLUMN_RENAMES)
            chunk = chunk[[column for column in COLUMN_RENAMES.values() if column in chunk.columns]]
            chunk["source_file"] = csv_path.name
            result.rows_extracted += len(chunk)

            accepted_chunk, rejected_rows = split_rejected_records(
                connection,
                chunk,
                csv_path.name,
                run_id,
                incremental,
            )
            insert_rejected_records(connection, rejected_rows)

            copy_chunk(connection, accepted_chunk, "bronze_311_requests")
            result.rows_loaded += len(accepted_chunk)
            result.rows_rejected += len(rejected_rows)
            print(
                "Processed "
                f"{result.rows_extracted:,} rows: "
                f"{result.rows_loaded:,} loaded, "
                f"{result.rows_rejected:,} rejected"
            )
    finally:
        connection.close()

    return result


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="NYC 311 bronze ingestion.")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV_PATH, help="NYC 311 CSV file path.")
    parser.add_argument("--chunksize", type=int, default=10000, help="Rows to process per pandas chunk.")
    parser.add_argument("--truncate", action="store_true", help="Truncate bronze table before loading.")
    parser.add_argument("--full-refresh", action="store_true", help="Reload all records instead of incrementally appending new request ids.")
    return parser.parse_args()


def main() -> None:
    load_dotenv(PROJECT_ROOT / ".env")
    args = parse_args()
    csv_path = args.csv if args.csv.is_absolute() else PROJECT_ROOT / args.csv

    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

    result = load_csv(
        csv_path,
        chunksize=args.chunksize,
        truncate=args.truncate or args.full_refresh,
        incremental=not args.full_refresh,
    )
    print(f"Bronze load complete: {result.rows_loaded:,} rows loaded")


if __name__ == "__main__":
    main()
