from dataclasses import dataclass
import dataclasses
import json


def _safe_int(val, default=0):
    try:
        return int(val)
    except (ValueError, TypeError):
        return default

@dataclass
class Ride:
    # PULocationID: int
    # DOLocationID: int
    # trip_distance: float
    # total_amount: float
    # tpep_pickup_datetime: int
    lpep_pickup_datetime: int
    lpep_dropoff_datetime: int
    PULocationID: int
    DOLocationID: int
    passenger_count: int
    trip_distance: float
    tip_amount: float
    total_amount: float


def ride_from_row(row):
    return Ride(
        # PULocationID=int(row['PULocationID']),
        # DOLocationID=int(row['DOLocationID']),
        # trip_distance=float(row['trip_distance']),
        # total_amount=float(row['total_amount']),
        # tpep_pickup_datetime=int(row['tpep_pickup_datetime'].timestamp() * 1000),
        lpep_pickup_datetime=int(row['lpep_pickup_datetime'].timestamp() * 1000),
        lpep_dropoff_datetime=int(row['lpep_dropoff_datetime'].timestamp() * 1000),
        PULocationID=_safe_int(row['PULocationID']),
        DOLocationID=_safe_int(row['DOLocationID']),
        passenger_count=_safe_int(row['passenger_count']),
        trip_distance=float(row['trip_distance']),
        tip_amount=float(row['tip_amount']),
        total_amount=float(row['total_amount'])
    )


def ride_serializer(data):
    ride_dict = dataclasses.asdict(data)
    ride_json = json.dumps(ride_dict).encode('utf-8')
    return ride_json



def ride_deserializer(data):
    json_str = data.decode('utf-8')
    ride_dict = json.loads(json_str)
    return Ride(**ride_dict)




