from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType
from pyspark.sql.functions import col, from_json, expr

# Initialize SparkSession
spark = SparkSession.builder \
    .appName("KafkaCassandraStream") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.0") \
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")

# Define schema for the incoming data (from Kafka)
movie_rating_schema = StructType([
    StructField("name", StringType(), False),
    StructField("movie", StringType(), False),
    StructField("rating", IntegerType(), False),
    StructField("timestamp", TimestampType(), False)
])

# Load the movie details from the 'netflix.csv' file
movies_file_path = '/vagrant/data/netflix.csv'
movies_df = spark.read.csv(movies_file_path, header=True, inferSchema=True)

# Cache the movie details since it is used in the join operation repeatedly
movies_df.cache()

# Kafka stream reading
df = spark.readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:29092") \
    .option("subscribe", "movies_ratings") \
    .option("startingOffsets", "latest") \
    .load()

# Extract the value from Kafka message and parse JSON into columns
parsed_df = df.selectExpr("CAST(value AS STRING)") \
    .select(from_json(col("value"), movie_rating_schema).alias("data")) \
    .select("data.*")

# Rename the 'rating' column in parsed_df to avoid ambiguity
parsed_df = parsed_df.withColumnRenamed("rating", "rating_movie")

# Join with the movie details from netflix.csv based on the movie title
# Generate a unique ID for each row using uuid()
enriched_df = parsed_df.join(movies_df, parsed_df.movie == movies_df.title, "inner") \
    .select(
        expr("uuid()").alias("id"),  # Generate a unique ID
        "show_id",                   # Added show_id
        "name", 
        "timestamp", 
        "movie", 
        "rating_movie",  # Renamed 'rating' to 'rating_movie'
        "duration", 
        "rating", 
        "release_year",
        "director",  # Assuming 'director' is in the CSV and Cassandra schema
        "country"     # Assuming 'country' is in the CSV and Cassandra schema

    )

# Define the function to write the enriched stream to Cassandra
def write_to_cassandra(batch_df, batch_id):
    batch_df.write \
        .format("org.apache.spark.sql.cassandra") \
        .mode("append") \
        .option("spark.cassandra.connection.host", "localhost") \
        .options(table="movie_ratings", keyspace="netflix") \
        .save()


# Configure the stream to persist every 30 seconds by using trigger
query = enriched_df.writeStream \
    .outputMode("append") \
    .foreachBatch(write_to_cassandra) \
    .trigger(processingTime='30 seconds') \
    .start()

query.awaitTermination()
