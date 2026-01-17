

-- =====================================
-- Question 3: Counting Short Trips
-- =====================================
-- Count trips in November 2025 with trip_distance <= 1 mile
-- Result: 8,007 trips

SELECT COUNT(*) AS trip_count
FROM green_taxi_data
WHERE lpep_pickup_datetime >= '2025-11-01'
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;

-- Result:
-- +-------+
-- | count |
-- |-------|
-- | 8007  |
-- +-------+


-- =====================================
-- Question 4: Longest Trip for Each Day
-- =====================================
-- Find the pickup day with the longest trip distance
-- Only consider trips with trip_distance < 100 miles
-- Result: 2025-11-14 with max distance of 88.03 miles

SELECT 
    DATE(lpep_pickup_datetime) AS pickup_day,
    MAX(trip_distance) AS max_distance
FROM green_taxi_data
WHERE trip_distance < 100
GROUP BY DATE(lpep_pickup_datetime)
ORDER BY max_distance DESC
LIMIT 1;

-- Result:
-- +------------+--------------+
-- | pickup_day | max_distance |
-- |------------+--------------|
-- | 2025-11-14 | 88.03        |
-- +------------+--------------+


-- =====================================
-- Question 5: Biggest Pickup Zone
-- =====================================
-- Find the pickup zone with the largest total_amount on November 18, 2025
-- Result: East Harlem North with total of 9,281.92

SELECT
    t."Zone" AS pickup_zone,
    SUM(g.total_amount) AS total_amount_sum
FROM
    green_taxi_data AS g
JOIN
    taxi_zone_lookup AS t
    ON g."PULocationID" = t."LocationID"
WHERE
    g.lpep_pickup_datetime >= '2025-11-18 00:00:00'
    AND g.lpep_pickup_datetime < '2025-11-19 00:00:00'
GROUP BY
    t."Zone"
ORDER BY
    total_amount_sum DESC
LIMIT 1;

-- Result:
-- +-------------------+-------------------+
-- | Zone              | total_amount_sum  |
-- |-------------------+-------------------|
-- | East Harlem North | 9281.92           |
-- +-------------------+-------------------+


-- =====================================
-- Question 6: Largest Tip
-- =====================================
-- Find the drop-off zone with the largest tip for passengers picked up 
-- from "East Harlem North" in November 2025
-- Result: Yorkville West with tip of $81.89

SELECT
    drop_zone."Zone" AS dropoff_zone_name,
    g.tip_amount
FROM
    green_taxi_data AS g
JOIN
    taxi_zone_lookup AS pick_zone
    ON g."PULocationID" = pick_zone."LocationID"
JOIN
    taxi_zone_lookup AS drop_zone
    ON g."DOLocationID" = drop_zone."LocationID"
WHERE
    pick_zone."Zone" = 'East Harlem North'
    AND g.lpep_pickup_datetime >= '2025-11-01'
    AND g.lpep_pickup_datetime < '2025-12-01'
ORDER BY
    g.tip_amount DESC
LIMIT 1;

-- Result:
-- +-------------------+------------+
-- | dropoff_zone_name | tip_amount |
-- |-------------------+------------|
-- | Yorkville West    | 81.89      |
-- +-------------------+------------+