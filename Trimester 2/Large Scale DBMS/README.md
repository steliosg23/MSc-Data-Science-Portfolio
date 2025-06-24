# Large Scale Data Management

This repository contains assignments from the Large Scale Data Management course, which explore distributed data processing through Hadoop MapReduce and real-time streaming with Apache Spark, Kafka, and Cassandra.

---

## 📌 Assignment 1 – Hadoop MapReduce Projects

This project was split into two parts focusing on the development and execution of Java-based MapReduce jobs.

### 🔧 Part I: Word Count on The Brothers Karamazov

- **Tools Used:** Hadoop, Java, Maven, Vagrant
- Executed the classic Word Count application on a custom input: *The Brothers Karamazov* (Gutenberg dataset).
- Modifications made to:
  - **Vagrantfile:** automated file retrieval and setup.
  - **Driver.java:** customized pathing and input/output handling.
- **Output:** Word frequency counts validated via terminal and HDFS logs.

### 🚗 Part II: Car Sales Data Aggregation

- **Dataset:** CSV of car sales transactions.
- **Task:** For each seller–month pair:
  - Identify the car with the **maximum (selling price – MMR)**.
  - Compute the **average price difference** for all cars in that group.
- **Implementation:**
  - Custom Java classes: `CarSalesMapper`, `CarSalesReducer`, `CarSalesDriver`
  - Job tested and validated through terminal execution logs and output samples.

---

## 📌 Assignment 2 – Real-Time Streaming with Kafka, Spark, and Cassandra

This project introduces a complete data pipeline using real-time technologies.

### 🎥 Part I: Kafka Movie Ratings Producer

- **Language:** Python (Asyncio, Faker, Pandas)
- **Simulation:** Movie ratings generated every 10 seconds for random users and movies.
- **Kafka Topic:** `movies_ratings`
- **Stream Message Contents:**
  - `name`, `movie`, `rating`, `timestamp`
- **Tooling:** `aiokafka` and asynchronous streaming logic

### 💡 Part II: Kafka Consumer & Spark Streaming to Cassandra

- **Language:** PySpark (Structured Streaming)
- **Enrichment:** Ratings stream enriched using movie metadata from CSV (`netflix.csv`)
- **Stream Sink:** Apache Cassandra
  - Writes data every 30 seconds to `netflix.movie_ratings` table
  - Schema includes `id`, `name`, `movie`, `timestamp`, `duration`, `rating_movie`, `release_year`, etc.
- **Spark-Kafka Integration:** Included all transformations and joins using `from_json`, `uuid`, and batch logic

### 🗃️ Part III: Cassandra Queries

- **Sample Queries:**
  - Avg. movie duration rated by user over specific period
  - List of movies rated by user during a specific time window
- **Cassandra Setup:**
  - Optimized for performance with proper keys, LZ4 compression, caching

---
