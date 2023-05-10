{{ config(materialized="view") }}

select
        dispatching_base_num,
        PARSE_DATETIME('%Y-%m-%d %H:%M:%S', pickup_datetime) pickup_datetime,
        PARSE_DATETIME('%Y-%m-%d %H:%M:%S', dropOff_datetime) dropOff_datetime,
        CAST(PUlocationID AS INT64) PUlocationID,
        CAST(DOlocationID AS INT64) DOlocationID,
        CAST(SR_Flag AS INT64) SR_Flag,
        Affiliated_base_number

  from {{ source("staging", "fhv_tripdata_2019") }}



-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}