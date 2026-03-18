from green_trips_common import create_green_trips_source, create_postgres_sink, create_table_env


def create_trip_distance_sink_postgres(t_env):
    return create_postgres_sink(
        t_env,
        "trip_distance_gt5",
        """
            PULocationID INTEGER,
            DOLocationID INTEGER,
            passenger_count INTEGER,
            trip_distance DOUBLE,
            total_amount DOUBLE,
            tip_amount DOUBLE,
            pickup_datetime TIMESTAMP(3),
            dropoff_datetime TIMESTAMP(3)
        """,
    )


def process_trip_distance():
    t_env = create_table_env()

    source_table = create_green_trips_source(t_env)
    sink_table = create_trip_distance_sink_postgres(t_env)

    t_env.execute_sql(
        f"""
        INSERT INTO {sink_table}
        SELECT
            PULocationID,
            DOLocationID,
            passenger_count,
            trip_distance,
            total_amount,
            tip_amount,
            event_timestamp AS pickup_datetime,
            TO_TIMESTAMP(lpep_dropoff_datetime, 'yyyy-MM-dd HH:mm:ss') AS dropoff_datetime
        FROM {source_table}
        WHERE trip_distance > 5.0
        """
    ).wait()


if __name__ == '__main__':
    process_trip_distance()

