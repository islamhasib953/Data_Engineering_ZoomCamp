
#!/usr/bin/env python
# coding: utf-8

import click
import pandas as pd
from sqlalchemy import create_engine
import pyarrow.parquet as pq
from time import time


@click.command()
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--table_name', default='green_taxi_data', help='Target table name')
@click.option('--file_path', default='green_tripdata_2025-11.parquet', help='Path to the parquet file')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, table_name, file_path):

    print(f"Connecting to postgres...")
    engine = create_engine(
        f'postgresql://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}')

    print(f"Reading parquet file: {file_path}")

    parquet_file = pq.ParquetFile(file_path)

    first_chunk = True
    total_chunks = 0

    for batch in parquet_file.iter_batches(batch_size=100000):
        t_start = time()

        df = batch.to_pandas()
        if first_chunk:
            df.head(0).to_sql(name=table_name, con=engine, if_exists='replace')
            first_chunk = False
        df.to_sql(name=table_name, con=engine, if_exists='append')

        t_end = time()
        total_chunks += 1
        print(
            f"Inserted chunk {total_chunks}, size: {len(df)} rows, took {(t_end - t_start):.3f} second")

    print("Finished ingesting data!")


if __name__ == '__main__':
    run()
