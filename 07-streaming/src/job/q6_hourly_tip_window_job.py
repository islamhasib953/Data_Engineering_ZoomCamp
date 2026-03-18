from green_trips_common import create_green_trips_source, create_postgres_sink, create_table_env


def create_sink(t_env):
    return create_postgres_sink(
        t_env,
        "q6_hourly_tips",
        """
            window_start TIMESTAMP(3),
            window_end TIMESTAMP(3),
            total_tip_amount DOUBLE,
            PRIMARY KEY (window_start, window_end) NOT ENFORCED
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
            window_end,
            SUM(tip_amount) AS total_tip_amount
        FROM TABLE(
            TUMBLE(TABLE {source_table}, DESCRIPTOR(event_timestamp), INTERVAL '1' HOUR)
        )
        GROUP BY window_start, window_end
        """
    ).wait()


if __name__ == "__main__":
    main()