from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, StreamTableEnvironment


BOOTSTRAP_SERVERS = "redpanda:29092"
POSTGRES_URL = "jdbc:postgresql://postgres:5432/postgres"
POSTGRES_USERNAME = "postgres"
POSTGRES_PASSWORD = "postgres"
TOPIC_NAME = "green-trips"


def create_table_env():
    env = StreamExecutionEnvironment.get_execution_environment()
    env.enable_checkpointing(10 * 1000)
    env.set_parallelism(1)

    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    return StreamTableEnvironment.create(env, environment_settings=settings)


def create_green_trips_source(t_env, table_name="green_trips_source"):
    source_ddl = f"""
        CREATE TABLE {table_name} (
            lpep_pickup_datetime STRING,
            lpep_dropoff_datetime STRING,
            PULocationID INTEGER,
            DOLocationID INTEGER,
            passenger_count INTEGER,
            trip_distance DOUBLE,
            tip_amount DOUBLE,
            total_amount DOUBLE,
            event_timestamp AS TO_TIMESTAMP(lpep_pickup_datetime, 'yyyy-MM-dd HH:mm:ss'),
            WATERMARK FOR event_timestamp AS event_timestamp - INTERVAL '5' SECOND
        ) WITH (
            'connector' = 'kafka',
            'properties.bootstrap.servers' = 'redpanda:29092',
            'topic' = 'green-trips',
            'scan.startup.mode' = 'earliest-offset',
            'format' = 'json',
            'json.fail-on-missing-field' = 'false',
            'json.ignore-parse-errors' = 'true'
        )
    """
    t_env.execute_sql(source_ddl)
    return table_name


def create_postgres_sink(t_env, table_name, schema_sql):
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            {schema_sql}
        ) WITH (
            'connector' = 'jdbc',
            'url' = 'jdbc:postgresql://postgres:5432/postgres',
            'table-name' = '{table_name}',
            'username' = 'postgres',
            'password' = 'postgres',
            'driver' = 'org.postgresql.Driver',
            'sink.buffer-flush.max-rows' = '1',
            'sink.buffer-flush.interval' = '1s'
        )
    """
    t_env.execute_sql(sink_ddl)
    return table_name