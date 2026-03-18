import json
from time import perf_counter

import pandas as pd
from kafka import KafkaProducer


URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/green_tripdata_2025-10.parquet"
TOPIC_NAME = "green-trips"
SERVER = "localhost:9092"
COLUMNS = [
    "lpep_pickup_datetime",
    "lpep_dropoff_datetime",
    "PULocationID",
    "DOLocationID",
    "passenger_count",
    "trip_distance",
    "tip_amount",
    "total_amount",
]


def _to_nullable_int(value):
    return None if pd.isna(value) else int(value)


def _to_nullable_float(value):
    return None if pd.isna(value) else float(value)


def _row_to_record(row):
    return {
        "lpep_pickup_datetime": row.lpep_pickup_datetime.strftime("%Y-%m-%d %H:%M:%S"),
        "lpep_dropoff_datetime": row.lpep_dropoff_datetime.strftime("%Y-%m-%d %H:%M:%S"),
        "PULocationID": _to_nullable_int(row.PULocationID),
        "DOLocationID": _to_nullable_int(row.DOLocationID),
        "passenger_count": _to_nullable_int(row.passenger_count),
        "trip_distance": _to_nullable_float(row.trip_distance),
        "tip_amount": _to_nullable_float(row.tip_amount),
        "total_amount": _to_nullable_float(row.total_amount),
    }


def main():
    df = pd.read_parquet(URL, columns=COLUMNS)

    producer = KafkaProducer(
        bootstrap_servers=[SERVER],
        value_serializer=lambda value: json.dumps(value).encode("utf-8"),
        linger_ms=20,
        batch_size=65536,
        request_timeout_ms=60000,
        metadata_max_age_ms=300000,
    )

    t0 = perf_counter()

    sent = 0
    for row in df.itertuples(index=False):
        producer.send(TOPIC_NAME, value=_row_to_record(row))
        sent += 1

    producer.flush()

    t1 = perf_counter()
    print(f"sent {sent} records")
    print(f"took {(t1 - t0):.2f} seconds")


if __name__ == "__main__":
    main()
