{{ config(materialized="view") }}

With tripdata as 
(
  select *,
    row_number() over(partition by cast(vendorid as integer), tpep_pickup_datetime) as rn
  from {{ source('staging','yellow_tripdata') }}
  where vendorid is not null 
)

select
    -- identifiers
    {{dbt_utils.surrogate_key(['vendorid', 'tpep_dropoff_datetime']) }} as tripid,
    cast(vendorid as integer) as vendorid,
    cast(ratecodeid as integer) as ratecodeid,
    cast(pulocationid as integer) as  pickup_locationid,
    cast(dolocationid as integer) as dropoff_locationid,
    
    -- timestamps
    cast(tpep_pickup_datetime as timestamp) as pickup_datetime,
    cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,
    
    -- trip info
    store_and_fwd_flag,
    cast(passenger_count as integer) as passenger_count,
    cast(trip_distance as numeric) as trip_distance,
    null as trip_type,

    -- payment info
    cast(fare_amount as numeric) as fare_amount,
    cast(extra as numeric) as extra,
    cast(mta_tax as numeric) as mta_tax,
    cast(tip_amount as numeric) as tip_amount,
    cast(tolls_amount as numeric) as tolls_amount,
    null as ehail_fee,
    cast(improvement_surcharge as numeric) as improvement_surcharge,
    cast(total_amount as numeric) as total_amount,
    cast(payment_type as integer) as payment_type,
    case 
        when cast(payment_type as integer) = 1 then 'Credit card'
        when cast(payment_type as integer) = 2 then 'Cash'
        when cast(payment_type as integer) = 3 then 'No charge'
        when cast(payment_type as integer) = 5 then 'Unknown'
        when cast(payment_type as integer) = 6 then 'Voided trip'
    end as payment_type_description,

    cast(congestion_surcharge as numeric) as congestion_surcharge
    
from tripdata
where rn = 1


-- dbt build --m <model.sql> --var 'is_test_run: false'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}