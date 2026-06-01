"""Load raw NYC 311 CSV data into the bronze table.

Usage:
    python src/extract_load_raw.py --csv data/raw/nyc_311_sample.csv --truncate
"""

from __future__ import annotations

import argparse
import os
from io import StringIO
from pathlib import Path

import pandas as pd
import psycopg2
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


def copy_chunk(connection, chunk: pd.DataFrame, table_name: str) -> None:
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


def load_csv(csv_path: Path, chunksize: int, truncate: bool) -> int:
    connection = psycopg2.connect(**build_connection_kwargs())
    create_tables(connection)

    if truncate:
        with connection.cursor() as cursor:
            cursor.execute("TRUNCATE TABLE bronze_311_requests;")
        connection.commit()

    total_rows = 0
    try:
        for chunk in pd.read_csv(csv_path, chunksize=chunksize, dtype=str, low_memory=False):
            chunk = chunk.rename(columns=COLUMN_RENAMES)
            chunk = chunk[[column for column in COLUMN_RENAMES.values() if column in chunk.columns]]
            chunk["source_file"] = csv_path.name

            copy_chunk(connection, chunk, "bronze_311_requests")
            total_rows += len(chunk)
            print(f"Loaded {total_rows:,} rows into bronze_311_requests")
    finally:
        connection.close()

    return total_rows


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Load raw NYC 311 CSV data into PostgreSQL.")
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV_PATH, help="Path to the NYC 311 CSV file.")
    parser.add_argument("--chunksize", type=int, default=10000, help="Rows to process per pandas chunk.")
    parser.add_argument("--truncate", action="store_true", help="Truncate bronze table before loading.")
    return parser.parse_args()


def main() -> None:
    load_dotenv(PROJECT_ROOT / ".env")
    args = parse_args()
    csv_path = args.csv if args.csv.is_absolute() else PROJECT_ROOT / args.csv

    if not csv_path.exists():
        raise FileNotFoundError(f"CSV file not found: {csv_path}")

    total_rows = load_csv(csv_path, chunksize=args.chunksize, truncate=args.truncate)
    print(f"Bronze load complete: {total_rows:,} rows")


if __name__ == "__main__":
    main()
