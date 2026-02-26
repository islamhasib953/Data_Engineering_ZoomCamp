"""@bruin

name: ingestion.trips

type: python

image: python:3.11

connection: duckdb-default

materialization:
  type: table
  strategy: append

columns:
  - name: taxi_type
    type: string
    description: Type of taxi (yellow, green, fhv, etc.)
  - name: pickup_datetime
    type: timestamp
    description: When the trip started
  - name: dropoff_datetime
    type: timestamp
    description: When the trip ended
  - name: passenger_count
    type: integer
    description: Number of passengers
  - name: trip_distance
    type: float
    description: Trip distance in miles
  - name: payment_type
    type: integer
    description: Payment type ID (FK to payment_lookup)
  - name: fare_amount
    type: float
    description: Base fare amount
  - name: total_amount
    type: float
    description: Total amount charged
  - name: extracted_at
    type: timestamp
    description: Timestamp when data was extracted

@bruin"""

import json
import os
from datetime import datetime
from io import BytesIO

import pandas as pd
import requests
from dateutil.relativedelta import relativedelta


def materialize():
    """
    Fetch NYC taxi trip data from TLC endpoint.
    
    Uses Bruin runtime context:
    - BRUIN_START_DATE / BRUIN_END_DATE: Date window for this run (YYYY-MM-DD)
    - BRUIN_VARS: Pipeline variables (JSON), includes taxi_types array
    
    Returns:
        pd.DataFrame: Concatenated trip data with extracted_at timestamp
    """
    start_date = datetime.strptime(os.environ['BRUIN_START_DATE'], '%Y-%m-%d')
    end_date = datetime.strptime(os.environ['BRUIN_END_DATE'], '%Y-%m-%d')
    bruin_vars = json.loads(os.environ.get('BRUIN_VARS', '{}'))
    taxi_types = bruin_vars.get('taxi_types', ['yellow', 'green'])
    
    print(f"Fetching data for {start_date.date()} to {end_date.date()}")
    print(f"Taxi types: {taxi_types}")
    
    months_to_fetch = []
    current = start_date
    while current <= end_date:
        months_to_fetch.append((current.year, current.month))
        current += relativedelta(months=1)
    
    months_to_fetch = list(set(months_to_fetch))
    
    all_dfs = []
    extracted_at = datetime.utcnow()
    
    for taxi_type in taxi_types:
        for year, month in months_to_fetch:
            url = f"https://d37ci6vzurychx.cloudfront.net/trip-data/{taxi_type}_tripdata_{year}-{month:02d}.parquet"
            print(f"Fetching: {url}")
            
            try:
                response = requests.get(url, timeout=60)
                response.raise_for_status()
                
                df = pd.read_parquet(BytesIO(response.content))
                
                df.columns = df.columns.str.lower()
                
                if taxi_type == 'yellow':
                    df = df.rename(columns={
                        'tpep_pickup_datetime': 'pickup_datetime',
                        'tpep_dropoff_datetime': 'dropoff_datetime'
                    })
                elif taxi_type == 'green':
                    df = df.rename(columns={
                        'lpep_pickup_datetime': 'pickup_datetime',
                        'lpep_dropoff_datetime': 'dropoff_datetime'
                    })
                
                df = df[[
                    'pickup_datetime',
                    'dropoff_datetime',
                    'passenger_count',
                    'trip_distance',
                    'payment_type',
                    'fare_amount',
                    'total_amount'
                ]].copy()
                
                df['taxi_type'] = taxi_type
                df['extracted_at'] = extracted_at
                
                df = df[
                    (df['pickup_datetime'].dt.date >= start_date.date()) &
                    (df['pickup_datetime'].dt.date <= end_date.date())
                ]
                
                all_dfs.append(df)
                print(f"  → Fetched {len(df):,} rows")
                
            except requests.exceptions.RequestException as e:
                print(f"  → Warning: Failed to fetch {url}: {e}")
                continue
    
    if not all_dfs:
        raise ValueError("No data fetched. Check URLs and date range.")
    
    result = pd.concat(all_dfs, ignore_index=True)
    print(f"\nTotal rows fetched: {len(result):,}")
    
    return result


