import json
import asyncio
import random
from aiokafka import AIOKafkaProducer
from faker import Faker
import pandas as pd
from datetime import datetime

# Load the movie titles
movies_file_path = '/vagrant/data/movies.csv'
movies_df = pd.read_csv(movies_file_path, header=None)

# Create a list of movie titles
movies_list = movies_df[0].tolist()

# Create a Faker instance
fake = Faker()

# Add names to the list
names = [fake.name() for _ in range(14)] + ["Stelios Giagkos"]

# Kafka topic
topic = 'movies_ratings'

# Serializer function
def serializer(value):
    return json.dumps(value).encode()

# Produce function
async def produce():
    producer = AIOKafkaProducer(
        bootstrap_servers='localhost:29092',
        value_serializer=serializer,
        compression_type="gzip"
    )

    await producer.start()

    while True:
        for _ in range(15):  # Send 15 entries
            name = random.choice(names)
            movie = random.choice(movies_list)
            rating = random.randint(1, 10)
            timestamp = datetime.now().isoformat()

            data = {
                "name": name,
                "movie": movie,
                "rating": rating,
                "timestamp": timestamp
            }

            await producer.send(topic, data)
            print(f"Sent: {data}")

        await asyncio.sleep(10)  # Wait for 10 seconds

    await producer.stop()

# Running the producer asynchronously
loop = asyncio.get_event_loop()
loop.run_until_complete(produce())