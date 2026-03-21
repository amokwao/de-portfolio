# Snowflake Project Portfolio

## Overview

This portfolio demonstrates end-to-end data engineering experience across structured and semi-structured ingestion, transformation, incremental processing, and data recovery using Snowflake. The projects are designed in production-style patterns that align with modern Spark/Python data platforms.

## Featured Projects

### 1. Employee ETL Pipeline (CSV -> Raw -> Transformed)

Built a batch pipeline to ingest structured employee data from internal stage files into a raw layer, transform it into analytics-ready models, and run workforce analytics.

Detailed project walkthrough: [Mini Project 1](snwflk_mini_project_1.md)

#### Project 1 highlights

- Designed medallion-style data flow: raw schema and transformed schema
- Implemented business transformations: full_name, annualized salary, tenure, experience level
- Added analysis layer: top earners, salary spend by department and year, tenure-based insights

#### Project 1 Snowflake capabilities

- Internal stages
- `COPY INTO`
- SQL transformations and window functions

### 2. Customer JSON Analytics Pipeline (VARIANT + Flatten)

Developed a semi-structured ingestion pipeline that loads JSON events into VARIANT columns, then flattens nested structures into relational tables for BI queries.

Detailed project walkthrough: [Mini Project 2](snwflk_mini_project_2.md)

#### Project 2 highlights

- Parsed nested customer, product, and transaction fields
- Built flatten model for region, country, product, and customer analytics
- Created KPI queries for sales trends, top products, and customer spend

#### Project 2 Snowflake capabilities

- VARIANT data type
- `LATERAL FLATTEN`
- `INSERT OVERWRITE` and aggregate analytics

### 3. Deep Nested Sales JSON Pipeline (Multi-level Flatten)

Implemented multi-level JSON flattening for hierarchical company -> region -> product data and produced comparative sales analytics.

Detailed project walkthrough: [Mini Project 3](snwflk_mini_project_3.md)

#### Project 3 highlights

- Flattened deeply nested arrays across multiple levels
- Normalized nested structures into analysis-ready format
- Delivered top/bottom performance cuts by company, region, and product

#### Project 3 Snowflake capabilities

- Multi-step `LATERAL FLATTEN`
- Structured projection from nested JSON paths
- Aggregation-driven reporting

### 4. Near Real-Time Ingestion with Snowpipe

Set up continuous ingestion from cloud object storage into Snowflake to support event-driven analytics.

#### Project 4 highlights

- Connected Snowflake to external S3 via storage integration
- Built auto-ingest pipe for JSON event ingestion
- Validated ingestion health and pipe status

#### Project 4 Snowflake capabilities

- Storage integration
- External stages
- Snowpipe (`AUTO_INGEST = TRUE`)

### 5. Incremental ETL with Streams and Tasks

Created CDC-like data movement patterns and automated target-table refreshes with scheduled tasks.

#### Project 5 highlights

- Used streams to capture table changes (standard and append-only)
- Implemented idempotent insert patterns from source to target
- Automated recurring transforms with scheduled tasks

#### Project 5 Snowflake capabilities

- Streams
- Tasks
- Incremental loading logic

### 6. Data Recovery and Environment Safety (Time Travel + Cloning)

Engineered recovery workflows for accidental deletes and rapid environment replication.

#### Project 6 highlights

- Restored deleted records using statement-based time travel
- Recovered dropped objects with `UNDROP`
- Created zero-copy clones for safe testing and rollback strategy

#### Project 6 Snowflake capabilities

- Time Travel
- `UNDROP`
- Zero-copy cloning

<!-- ## Recruiter-facing Value

- Demonstrates practical ownership of ingestion, modeling, operations, and resiliency
- Shows transferable architecture skills for Spark/Python-scale systems
- Reflects production mindset: automation, recoverability, and scalable data design -->
