# Data Engineering Zoomcamp 2026 - Module 1 Homework

Solutions for Docker, SQL, and Terraform assignments.

---

## Environment Setup

### Prerequisites
- Docker & Docker Compose
- PostgreSQL 17
- pgAdmin 4
- Python 3.13

### Data Ingestion
Downloaded and processed NYC Green Taxi trip data for November 2025 along with taxi zone lookup data.

```bash
wget https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-11.parquet
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv
```

---

## Solutions

### Question 1: Docker Image Version Check

Verified pip version in the official Python 3.13 Docker image.

```bash
docker run -it --entrypoint bash python:3.13
pip --version
```

**Answer: 25.3**

---

### Question 2: Docker Networking Configuration

Analyzed the docker-compose configuration to determine the correct connection parameters for pgAdmin to connect to PostgreSQL.

Given the service name `db` and port mapping `5433:5432`, the connection details are:
- Hostname: `db` (service name within Docker network)
- Port: `5433`

**Answer: db:5433**

---

### Question 3: Trip Distance Analysis

Analyzed trips for November 2025 to count rides with distance ≤ 1 mile.

```sql
SELECT COUNT(*)
FROM green_taxi_data
WHERE lpep_pickup_datetime >= '2025-11-01'
  AND lpep_pickup_datetime < '2025-12-01'
  AND trip_distance <= 1;
```

**Answer: 8,007 trips**

---

### Question 4: Maximum Daily Trip Distance

Identified the day with the longest trip distance (excluding outliers > 100 miles).

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
- Date: 2025-11-14
- Distance: 88.03 miles

**Answer: 2025-11-14**

---

### Question 5: Top Revenue Pickup Zone

Calculated total revenue by pickup zone for November 18, 2025.

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
- Zone: East Harlem North
- Total Amount: $9,281.92

**Answer: East Harlem North**

---

### Question 6: Highest Tip Analysis

Found the drop-off zone with the highest tip for trips originating from East Harlem North in November 2025.

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
- Drop-off Zone: Yorkville West
- Tip Amount: $81.89

**Answer: Yorkville West**

---

### Question 7: Terraform Workflow

The correct sequence for Terraform operations:

1. **Initialize**: `terraform init` - Downloads providers and configures backend
2. **Apply**: `terraform apply -auto-approve` - Creates/updates infrastructure without manual confirmation
3. **Destroy**: `terraform destroy` - Removes all managed resources

**Answer: terraform init, terraform apply -auto-approve, terraform destroy**

---

## Database Schema

### Tables Used
- `green_taxi_data` - Trip records with pickup/dropoff times, distances, amounts
- `taxi_zone_lookup` - Zone ID to zone name mapping

### Key Columns
- `lpep_pickup_datetime` - Trip start timestamp
- `trip_distance` - Distance in miles
- `total_amount` - Total fare amount
- `tip_amount` - Tip given by passenger
- `PULocationID` - Pickup location zone ID
- `DOLocationID` - Drop-off location zone ID

---

## Notes

All SQL queries were executed against a PostgreSQL 17 database running in Docker. Data was ingested using a custom Python script that reads Parquet files and loads them into PostgreSQL tables.

See [hm.sql](./hm.sql) for the complete SQL query collection.
