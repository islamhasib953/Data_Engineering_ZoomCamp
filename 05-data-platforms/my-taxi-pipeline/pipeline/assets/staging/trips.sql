/* @bruin

name: staging.trips

type: duckdb.sql

depends:
  - ingestion.trips
  - ingestion.payment_lookup

materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp

columns:
  - name: trip_id
    type: string
    description: Unique identifier for each trip (hash of trip details)
    primary_key: true
    nullable: false
    checks:
      - name: not_null
      - name: unique
  - name: taxi_type
    type: string
    description: Type of taxi (yellow, green, fhv)
    checks:
      - name: not_null
  - name: pickup_datetime
    type: timestamp
    description: Trip start time
    checks:
      - name: not_null
  - name: dropoff_datetime
    type: timestamp
    description: Trip end time
    checks:
      - name: not_null
  - name: passenger_count
    type: integer
    description: Number of passengers
    checks:
      - name: positive
  - name: trip_distance
    type: float
    description: Trip distance in miles
    checks:
      - name: non_negative
  - name: payment_type_id
    type: integer
    description: Payment type ID
    checks:
      - name: not_null
  - name: payment_type_name
    type: string
    description: Payment type name (from lookup)
    checks:
      - name: not_null
  - name: fare_amount
    type: float
    description: Base fare
    checks:
      - name: non_negative
  - name: total_amount
    type: float
    description: Total charge
    checks:
      - name: non_negative

custom_checks:
  - name: no_negative_trip_duration
    description: Ensure dropoff is after pickup
    query: |
      SELECT COUNT(*)
      FROM staging.trips
      WHERE dropoff_datetime <= pickup_datetime
    value: 0
  - name: reasonable_trip_distance
    description: Check for unreasonable trip distances (>500 miles)
    query: |
      SELECT COUNT(*)
      FROM staging.trips
      WHERE trip_distance > 500
    value: 0

@bruin */


WITH filtered_trips AS (
  SELECT
    t.*,
    p.payment_type_name
  FROM ingestion.trips t
  LEFT JOIN ingestion.payment_lookup p
    ON t.payment_type = p.payment_type_id
  WHERE t.pickup_datetime >= '{{ start_datetime }}'
    AND t.pickup_datetime < '{{ end_datetime }}'
    AND t.pickup_datetime IS NOT NULL
    AND t.dropoff_datetime IS NOT NULL
    AND t.dropoff_datetime > t.pickup_datetime
    AND t.passenger_count > 0
    AND t.trip_distance >= 0
    AND t.fare_amount >= 0
    AND t.total_amount >= 0
    AND t.payment_type IS NOT NULL
),

deduplicated AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY 
        taxi_type,
        pickup_datetime,
        dropoff_datetime,
        passenger_count,
        trip_distance,
        fare_amount,
        total_amount
      ORDER BY extracted_at DESC
    ) AS row_num
  FROM filtered_trips
)

SELECT
  MD5(
    taxi_type || 
    CAST(pickup_datetime AS VARCHAR) || 
    CAST(dropoff_datetime AS VARCHAR) ||
    CAST(passenger_count AS VARCHAR) ||
    CAST(trip_distance AS VARCHAR) ||
    CAST(fare_amount AS VARCHAR) ||
    CAST(total_amount AS VARCHAR)
  ) AS trip_id,
  taxi_type,
  pickup_datetime,
  dropoff_datetime,
  passenger_count,
  trip_distance,
  payment_type AS payment_type_id,
  payment_type_name,
  fare_amount,
  total_amount
FROM deduplicated
WHERE row_num = 1
