# Module 05: Data Platforms - Homework

> **Course:** Data Engineering Zoomcamp  
> **Module:** 05 - Data Platforms  
> **Tool:** Bruin  
> **Project:** NYC Taxi Data Pipeline

---

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Questions and Answers](#questions-and-answers)
- [Project Structure](#project-structure)
- [Pipeline Architecture](#pipeline-architecture)
- [How to Run](#how-to-run)

---

## 🎯 Project Overview

This project implements a complete **data pipeline** using **Bruin** for processing NYC taxi trip data from the TLC (Taxi and Limousine Commission) dataset.

### Pipeline Features:
- ✅ **Ingestion Layer:** Fetch data from TLC CloudFront endpoint
- ✅ **Staging Layer:** Clean, deduplicate, and enrich data
- ✅ **Reports Layer:** Aggregate metrics by date, taxi type, and payment type
- ✅ **Quality Checks:** Built-in and custom checks across all layers
- ✅ **Incremental Processing:** Time-interval strategy for efficiency
- ✅ **DuckDB Backend:** Lightweight, embedded analytics database

---

## ❓ Questions and Answers

### Question 1: Bruin Pipeline Structure

**In a Bruin project, what are the required files/directories?**

**Options:**
- [ ] `bruin.yml` and `assets/`
- [ ] `.bruin.yml` and `pipeline.yml` (assets can be anywhere)
- [x] **`.bruin.yml` and `pipeline/` with `pipeline.yml` and `assets/`**
- [ ] `pipeline.yml` and `assets/` only

**✅ Answer:** `.bruin.yml` and `pipeline/` with `pipeline.yml` and `assets/`

**💡 Explanation:**

A Bruin project requires:
- **`.bruin.yml`** - Project configuration file (connections, environments)
- **`pipeline/`** directory containing:
  - `pipeline.yml` - Pipeline configuration (name, schedule, variables)
  - `assets/` - Directory with all assets (SQL, Python, YAML files)

---

### Question 2: Materialization Strategies

**You're building a pipeline that processes NYC taxi data organized by month based on `pickup_datetime`. Which incremental strategy is best for processing a specific interval period by deleting and inserting data for that time period?**

**Options:**
- [ ] `append` - always add new rows
- [ ] `replace` - truncate and rebuild entirely
- [x] **`time_interval` - incremental based on a time column**
- [ ] `view` - create a virtual table only

**✅ Answer:** `time_interval` - incremental based on a time column

**💡 Explanation:**

The `time_interval` strategy is ideal for time-based data because it:
1. **Deletes** rows where the `incremental_key` falls within the run's time window
2. **Inserts** new data for that same time period
3. Allows efficient reprocessing of specific date ranges without affecting other data
4. Works perfectly with date/timestamp columns like `pickup_datetime`

**Example in our pipeline:**
```yaml
materialization:
  type: table
  strategy: time_interval
  incremental_key: pickup_datetime
  time_granularity: timestamp
```

This is used in both `staging.trips` and `reports.trips_report`.

---

### Question 3: Pipeline Variables

**You have the following variable defined in `pipeline.yml`:**

```yaml
variables:
  taxi_types:
    type: array
    items:
      type: string
    default: ["yellow", "green"]
```

**How do you override this when running the pipeline to only process yellow taxis?**

**Options:**
- [ ] `bruin run --taxi-types yellow`
- [ ] `bruin run --var taxi_types=yellow`
- [x] **`bruin run --var 'taxi_types=["yellow"]'`**
- [ ] `bruin run --set taxi_types=["yellow"]`

**✅ Answer:** `bruin run --var 'taxi_types=["yellow"]'`

**💡 Explanation:**

To override pipeline variables in Bruin:
- Use `--var` flag followed by the variable name
- For array variables, provide the value in **JSON format**
- Use quotes around the JSON array to ensure proper parsing
- The variable must match the type defined in `pipeline.yml`

**Examples:**
```bash
# Process only yellow taxis
bruin run --var 'taxi_types=["yellow"]'

# Process yellow and green taxis (default)
bruin run

# Process multiple specific types
bruin run --var 'taxi_types=["yellow","green","fhv"]'
```

---

### Question 4: Running with Dependencies

**You've modified the `ingestion/trips.py` asset and want to run it plus all downstream assets. Which command should you use?**

**Options:**
- [ ] `bruin run ingestion.trips --all`
- [x] **`bruin run ingestion/trips.py --downstream`**
- [ ] `bruin run pipeline/trips.py --recursive`
- [ ] `bruin run --select ingestion.trips+`

**✅ Answer:** `bruin run ingestion/trips.py --downstream`

**💡 Explanation:**

The `--downstream` flag tells Bruin to:
1. Run the specified asset (`ingestion/trips.py`)
2. Automatically run all assets that depend on it
3. Execute in the correct dependency order

**Dependency chain in our pipeline:**
```
ingestion/trips.py
    ↓
staging/trips.sql
    ↓
reports/trips_report.sql
```

Running `bruin run ingestion/trips.py --downstream` will execute all three assets.

---

### Question 5: Quality Checks

**You want to ensure the `pickup_datetime` column in your trips table never has NULL values. Which quality check should you add to your asset definition?**

**Options:**
- [ ] `name: unique`
- [x] **`name: not_null`**
- [ ] `name: positive`
- [ ] `name: accepted_values, value: [not_null]`

**✅ Answer:** `name: not_null`

**💡 Explanation:**

Quality checks in Bruin are defined at the column level:

```yaml
columns:
  - name: pickup_datetime
    type: timestamp
    description: Trip start time
    checks:
      - name: not_null  # ✅ Ensures no NULL values
```

**Common built-in checks:**
- `not_null` - Column cannot have NULL values
- `unique` - All values must be unique
- `positive` - Values must be > 0
- `non_negative` - Values must be ≥ 0
- `accepted_values` - Values must be in a defined list

**Example in our staging layer:**
```yaml
columns:
  - name: pickup_datetime
    type: timestamp
    checks:
      - name: not_null
  - name: trip_id
    type: string
    primary_key: true
    checks:
      - name: not_null
      - name: unique
```

---

### Question 6: Lineage and Dependencies

**After building your pipeline, you want to visualize the dependency graph between assets. Which Bruin command should you use?**

**Options:**
- [ ] `bruin graph`
- [ ] `bruin dependencies`
- [x] **`bruin lineage`**
- [ ] `bruin show`

**✅ Answer:** `bruin lineage`

**💡 Explanation:**

The `bruin lineage` command:
- Displays the dependency graph between all assets
- Shows which assets depend on which
- Helps understand data flow through the pipeline
- Useful for debugging and documentation

**Example output:**
```
ingestion.payment_lookup (seed)
ingestion.trips (python) → staging.trips (sql) → reports.trips_report (sql)
```

**Other useful Bruin commands:**
- `bruin validate` - Check pipeline configuration
- `bruin run` - Execute pipeline assets
- `bruin connections` - List configured connections

---

### Question 7: First-Time Run

**You're running a Bruin pipeline for the first time on a new DuckDB database. What flag should you use to ensure tables are created from scratch?**

**Options:**
- [ ] `--create`
- [ ] `--init`
- [x] **`--full-refresh`**
- [ ] `--truncate`

**✅ Answer:** `--full-refresh`

**💡 Explanation:**

The `--full-refresh` flag:
- Ignores incremental strategies
- Recreates all tables from scratch
- Processes all data regardless of date windows
- Essential for first-time runs or data corrections

**Usage examples:**
```bash
# First-time run - create everything from scratch
bruin run --full-refresh

# Full refresh for specific asset and downstream
bruin run ingestion/trips.py --downstream --full-refresh

# Regular incremental run (after first time)
bruin run --start-date 2024-01-01 --end-date 2024-01-31
```

**When to use `--full-refresh`:**
- ✅ First-time pipeline execution
- ✅ Database schema changes
- ✅ Data corruption recovery
- ✅ Reprocessing historical data completely

---

## 📁 Project Structure

```
my-taxi-pipeline/
├── .bruin.yml                          # Project configuration
│   └── environments:
│       └── default:
│           └── connections:
│               └── duckdb: duckdb-default
│
└── pipeline/
    ├── pipeline.yml                    # Pipeline configuration
    │   ├── name: nyc_taxi
    │   ├── schedule: daily
    │   ├── start_date: "2024-01-01"
    │   └── variables:
    │       └── taxi_types: ["yellow", "green"]
    │
    └── assets/
        ├── ingestion/                  # Layer 1: Raw data ingestion
        │   ├── payment_lookup.asset.yml  # Seed: Payment types CSV
        │   ├── payment_lookup.csv
        │   ├── trips.py                  # Python: Fetch from TLC
        │   └── requirements.txt
        │
        ├── staging/                    # Layer 2: Clean & deduplicate
        │   └── trips.sql                 # SQL: Clean, dedupe, enrich
        │
        └── reports/                    # Layer 3: Aggregations
            └── trips_report.sql          # SQL: Daily aggregated metrics
```
