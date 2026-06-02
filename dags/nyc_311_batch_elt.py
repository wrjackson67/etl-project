"""Airflow DAG for the NYC 311 batch ELT pipeline."""

from __future__ import annotations

from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator


PROJECT_DIR = "/opt/airflow/project"


default_args = {
    "owner": "data-engineering",
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}


with DAG(
    dag_id="nyc_311_batch_elt",
    description="Incrementally load NYC 311 records, transform bronze to gold, and run dbt tests.",
    default_args=default_args,
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["nyc-311", "elt", "portfolio"],
) as dag:
    run_pipeline_and_dbt_models = BashOperator(
        task_id="run_pipeline_and_dbt_models",
        bash_command=(
            f"cd {PROJECT_DIR} && "
            "python -m pip install -r requirements.txt && "
            "python src/run_pipeline.py --csv data/raw/nyc_311_sample.csv --skip-dbt-tests"
        ),
    )

    run_dbt_tests = BashOperator(
        task_id="run_dbt_tests",
        bash_command=(
            f"cd {PROJECT_DIR} && "
            "DBT_PROFILES_DIR=dbt dbt test"
        ),
    )

    run_pipeline_and_dbt_models >> run_dbt_tests
