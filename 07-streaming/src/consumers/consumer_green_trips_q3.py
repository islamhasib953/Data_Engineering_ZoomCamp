import json

from kafka import KafkaConsumer


TOPIC_NAME = "green-trips"
SERVER = "localhost:9092"


def main():
    consumer = KafkaConsumer(
        TOPIC_NAME,
        bootstrap_servers=[SERVER],
        auto_offset_reset="earliest",
        enable_auto_commit=False,
        group_id=None,
        value_deserializer=lambda value: json.loads(value.decode("utf-8")),
        consumer_timeout_ms=5000,
    )

    count_over_5 = 0
    total_messages = 0

    for message in consumer:
        total_messages += 1
        trip_distance = message.value.get("trip_distance")
        if trip_distance is not None and float(trip_distance) > 5.0:
            count_over_5 += 1

    consumer.close()

    print(f"total_messages={total_messages}")
    print(f"trip_distance_gt_5={count_over_5}")


if __name__ == "__main__":
    main()