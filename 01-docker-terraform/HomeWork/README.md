# Module 1 Homework: Docker & SQL

**Data Engineering Zoomcamp 2026**  
**Due Date:** 27 January 2026 01:59 (local time)

---

## Question 1: Understanding Docker Images

**Question:** Run docker with the `python:3.13` image. Use an entrypoint bash to interact with the container. What's the version of pip in the image?

**Answer:** `25.3` ✓

**Command:**
```bash
docker run -it --entrypoint bash python:3.13
pip --version
```

---

## Question 2: Understanding Docker Networking and Docker-Compose

**Question:** Given the docker-compose.yaml, what is the hostname and port that pgadmin should use to connect to the postgres database?

**Answer:** `db:5433` ✓

**Explanation:**
- **Hostname:** `db` (the service name in docker-compose)
- **Port:** `5433` (the port mapping in docker-compose)
- From pgadmin container's perspective, it connects to the service name `db` on port 5433

---

## Question 3: Counting Short Trips

**Question:** For the trips in November 2025 (lpep_pickup_datetime between '2025-11-01' and '2025-12-01', exclusive of the upper bound), how many trips had a trip_distance of less than or equal to 1 mile?

**Answer:** `8,007` ✓

**SQL Query:**
```sql
SELECT COUNT(*)
FROM green_taxi_data
WHERE lpep_pickup_datetime >= '2025-11-01'
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;
```

**Result:**
```
+-------+
| count |
|-------|
| 8007  |
+-------+
```

---

## Question 4: Longest Trip for Each Day

**Question:** Which was the pick up day with the longest trip distance? Only consider trips with trip_distance less than 100 miles (to exclude data errors). Use the pick up time for your calculations.

**Answer:** `2025-11-14` ✓

**SQL Query:**
```sql
SELECT 
    DATE(lpep_pickup_datetime) AS pickup_day,
    MAX(trip_distance) AS max_distance
FROM green_taxi_data
WHERE trip_distance < 100
GROUP BY DATE(lpep_pickup_datetime)
ORDER BY max_distance DESC
LIMIT 1;
```

**Result:**
```
+------------+--------------+
| pickup_day | max_distance |
|------------+--------------|
| 2025-11-14 | 88.03        |
+------------+--------------+
```

---

## Question 5: Biggest Pickup Zone

**Question:** Which was the pickup zone with the largest total_amount (sum of all trips) on November 18th, 2025?

**Answer:** `East Harlem North` ✓

**SQL Query:**
```sql
SELECT
    t."Zone",
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
```

**Result:**
```
+-------------------+-------------------+
| Zone              | total_amount_sum  |
|-------------------+-------------------|
| East Harlem North | 9281.92           |
+-------------------+-------------------+
```

---

## Question 6: Largest Tip

**Question:** For the passengers picked up in the zone named "East Harlem North" in November 2025, which was the drop off zone that had the largest tip?

**Answer:** `Yorkville West` ✓

**SQL Query:**
```sql
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
```

**Result:**
```
+-------------------+------------+
| dropoff_zone_name | tip_amount |
|-------------------+------------|
| Yorkville West    | 81.89      |
+-------------------+------------+
```

---

## Question 7: Terraform Workflow

**Question:** Which of the following sequences, respectively, describes the workflow for:
1. Downloading the provider plugins and setting up backend
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform

**Answer:** `terraform init, terraform apply -auto-approve, terraform destroy` ✓

**Explanation:**
- **`terraform init`**: Downloads provider plugins and sets up backend
- **`terraform apply -auto-approve`**: Generates and auto-executes the plan
- **`terraform destroy`**: Removes all resources managed by Terraform

---

## Data Sources

**Green Taxi Trips Data (November 2025):**
```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet
```

**Taxi Zone Lookup:**
```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

---

## Repository Information

This repository contains the homework solutions for Module 1 of the Data Engineering Zoomcamp 2026.

**Course Link:** [Data Engineering Zoomcamp](https://github.com/DataTalksClub/data-engineering-zoomcamp/)

**Submission Form:** [Submit Homework](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw1)
