select
    run.run_id,
    run.pipeline_name,
    run.status,
    run.source_file,
    run.run_started_at,
    run.run_finished_at,
    run.duration_seconds,
    run.rows_extracted,
    run.rows_loaded,
    run.rows_rejected,
    round(
        (run.rows_rejected::numeric / nullif(run.rows_extracted, 0)) * 100,
        2
    ) as rejected_record_rate,
    run.last_loaded_request_id,
    run.error_message
from {{ source('public', 'pipeline_run_log') }} run
