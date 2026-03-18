from green_trips_common import create_green_trips_source, create_postgres_sink, create_table_env


def create_sink(t_env):
    return create_postgres_sink(
        t_env,
        "q4_pu_tumbling_window",
        """
            window_start TIMESTAMP(3),
            PULocationID INTEGER,
            num_trips BIGINT,
            PRIMARY KEY (window_start, PULocationID) NOT ENFORCED
        """,
    )


def main():
    t_env = create_table_env()
    source_table = create_green_trips_source(t_env)
    sink_table = create_sink(t_env)

    t_env.execute_sql(
        f"""
        INSERT INTO {sink_table}
        SELECT
            window_start,
            PULocationID,
            COUNT(*) AS num_trips
        FROM TABLE(
            TUMBLE(TABLE {source_table}, DESCRIPTOR(event_timestamp), INTERVAL '5' MINUTES)
        )
        GROUP BY window_start, PULocationID
        """
    ).wait()


if __name__ == "__main__":
    main()