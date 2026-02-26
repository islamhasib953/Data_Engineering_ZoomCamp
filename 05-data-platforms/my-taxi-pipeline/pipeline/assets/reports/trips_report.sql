/* @bruin

name: reports.trips_report

type: duckdb.sql

depends:
  - staging.trips

materialization:
  type: table
  strategy: time_interval
  incremental_key: trip_date
  time_granularity: date

columns:
  - name: trip_date
    type: date
    description: Calendar date of trips (derived from pickup_datetime)
    primary_key: true
    checks:
      - name: not_null
  - name: taxi_type
    type: string
    description: Type of taxi (yellow, green, fhv)
    primary_key: true
    checks:
      - name: not_null
  - name: payment_type_name
    type: string
    description: Payment method name
    primary_key: true
    checks:
      - name: not_null
  - name: trip_count
    type: bigint
    description: Total number of trips
    checks:
      - name: not_null
      - name: positive
  - name: total_passengers
    type: bigint
    description: Total number of passengers across all trips
    checks:
      - name: not_null
      - name: non_negative
  - name: total_distance
    type: double
    description: Total trip distance in miles
    checks:
      - name: not_null
      - name: non_negative
  - name: total_fare_amount
    type: double
    description: Total fare amount (sum of all base fares)
    checks:
      - name: not_null
      - name: non_negative
  - name: total_amount
    type: double
    description: Total amount charged (sum of all totals)
    checks:
      - name: not_null
      - name: non_negative
  - name: avg_trip_distance
    type: double
    description: Average trip distance in miles
    checks:
      - name: non_negative
  - name: avg_fare_amount
    type: double
    description: Average fare amount per trip
    checks:
      - name: non_negative
  - name: avg_total_amount
    type: double
    description: Average total amount per trip
    checks:
      - name: non_negative
  - name: avg_passengers_per_trip
    type: double
    description: Average number of passengers per trip
    checks:
      - name: non_negative

custom_checks:
  - name: total_should_exceed_fare
    description: Total amount should be >= fare amount for each group
    query: |
      SELECT COUNT(*)
      FROM reports.trips_report
      WHERE total_amount < total_fare_amount
    value: 0
  - name: reasonable_daily_trip_counts
    description: Check for suspiciously high daily trip counts (>1M trips per group)
    query: |
      SELECT COUNT(*)
      FROM reports.trips_report
      WHERE trip_count > 1000000
    value: 0
  - name: averages_match_totals
    description: Verify avg calculations are consistent with totals
    query: |
      SELECT COUNT(*)
      FROM reports.trips_report
      WHERE ABS(avg_trip_distance - (total_distance / trip_count)) > 0.01
    value: 0

@bruin */


SELECT
  CAST(pickup_datetime AS DATE) AS trip_date,
  taxi_type,
  payment_type_name,
  
  COUNT(*) AS trip_count,
  SUM(passenger_count) AS total_passengers,
  
  SUM(trip_distance) AS total_distance,
  AVG(trip_distance) AS avg_trip_distance,
  
  SUM(fare_amount) AS total_fare_amount,
  SUM(total_amount) AS total_amount,
  AVG(fare_amount) AS avg_fare_amount,
  AVG(total_amount) AS avg_total_amount,
  
  AVG(CAST(passenger_count AS DOUBLE)) AS avg_passengers_per_trip

FROM staging.trips
WHERE pickup_datetime >= '{{ start_datetime }}'
  AND pickup_datetime < '{{ end_datetime }}'
GROUP BY
  CAST(pickup_datetime AS DATE),
  taxi_type,
  payment_type_name
ORDER BY
  trip_date DESC,
  taxi_type,
  payment_type_name
