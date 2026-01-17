#!/usr/bin/env python
# coding: utf-8

import click
import pandas as pd
from sqlalchemy import create_engine


@click.command()
@click.option('--pg-user', default='root', help='PostgreSQL user')
@click.option('--pg-pass', default='root', help='PostgreSQL password')
@click.option('--pg-host', default='localhost', help='PostgreSQL host')
@click.option('--pg-port', default=5432, type=int, help='PostgreSQL port')
@click.option('--pg-db', default='ny_taxi', help='PostgreSQL database name')
@click.option('--target-table', default='taxi_zone_lookup', help='Target table name')
def run(pg_user, pg_pass, pg_host, pg_port, pg_db, target_table):

    url = 'https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv'

    print(f"Downloading and ingesting data from {url}...")

    engine = create_engine(
        f'postgresql://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_db}')

    df = pd.read_csv(url)

    df.to_sql(name=target_table, con=engine, if_exists='replace', index=False)

    print(f"Done! {len(df)} zones loaded into table '{target_table}'.")


if __name__ == '__main__':
    run()
