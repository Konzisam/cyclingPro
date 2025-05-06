<p align="center">
  <img src="https://github.com/Konzisam/cyclingPro/blob/master/docs/images/bike.jpeg" alt="logo" width="250"/>
</p>

# Cycling Pro Data Platform – Case Study
## Overview
Cycling Pro is a growing bicycle and equipment retail that sells products as is seeing steady growth. Currently, customer and product data are siloed in separate CRM and ERP systems. To enhance operational efficiency and support data-driven decision-making, a new data platform is being developed.

As a Data Engineer, my responsibility is to design and implement a scalable, unified data solution that integrates these disparate systems into an analytics-ready environment. This solution aims to reduce the time required for analytics and streamline data acquisition from source systems, enabling faster insights and better business outcomes.

This document outlines the architecture, decisions, challenges, and solutions that formed the backbone of the data platform.

## Scenario
Cycling Pro, like many small-to-medium businesses, was not initially built to scale initially. Data duplication, inconsistent data, and lack of synchronization have become major bottlenecks.

The current system includes:

* CRM application (customer ,products and sales)

* ERP system (product, customer and location)

The need is to integrate the ERP and CRM data to a warehouse:

* Integration across systems

* A single source of truth

* Analytics for better forecasting and strategy

## Objectives
### Data Warehouse Development
* **Goal:** Build a modern data warehouse to consolidate and unify sales data, enabling analytics and informed decision-making across the organization.

#### Specifications:

* **Connect to Sources:** Ingest data from two core systems (ERP and CRM), and load to warehouse and keep a copy in datalake for historical storage/backup.

* **Perform Integrity:** Perform cleansing and transformation to resolve inconsistencies and ensure reliable data and load it to staging.

* **Data Integration:** Unify both datasets into a single, intuitive data model optimized for analytical queries.

* **Scope:** Focus on processing the latest available data; historical tracking or time-based versioning is not within scope.

* **Documentation:** Deliver clear, accessible documentation of the data model to support business users and engineering team as well.

### Business Intelligence & Analytics
Leverage SQL-based analytics to generate actionable insights that support strategic business decisions.

Focus Areas:

* **Customer Behavior:** Understand patterns, segmentation, and lifecycle metrics.

* **Product Performance:** Evaluate product success across categories and sales channels.

* **Sales Trends:** Analyze trends over time to inform marketing, inventory, and operational planning.

These analytics aim to provide key performance indicators (KPIs) and interactive dashboards that empower stakeholders with data-driven insights.


## Technical Architecture & Approach
To meet these goals, the following objectives were established, with careful technology selections made to ensure scalability, flexibility, and maintainability:

* #### Centralized Data Lake / Warehouse

    _**Reason:**_ Consolidating data from ERP, CRM, and sales systems into a single source of truth eliminates data silos, ensures consistency, and enables holistic analytics.
  * **Snowflake as a Data Warehouse:** - Snowflake’s ability to scale compute independently and cost-efficiency, to support analytical workloads, and simplify data integration without the need for infrastructure management, making it well-suited for consolidating ERP and CRM data into a single analytical environment
  * **DuckDB for Local Warehouse Testing** -  Used as a lightweight, in-memory analytics database to simulate the data warehouse environment locally. This enables fast, efficient testing and validation of dbt models and transformations before deploying changes to production in Snowflake.

* #### Scalable Pipeline using DLT, dbt, and Dagster

    _**Reason:**_ These tools support a modular and scalable ETL architecture and integrate smoothly.

    * **_dlt:_** (By DltHub) an open source Python library that makes data loading easy, which simplifies moving the data between the ERP and CRM sources to snowflake. 

  * **_dbt:_** Perform transformation logic in SQL, and develop models to meet our goal while promoting analytics engineering best practices like version control, testing and documentation.

  * **_Dagster:_** Offers orchestration with strong support for observability and modular pipeline design. Will be used to trigger the workflows on a schedule and provide visibility for successes or failures

  
## Architecture
<p align="center">
  <img src="./docs/images/architechture.png" alt="logo" />
</p>

1. **Data Ingestion (dlt):**\
Data from ERP and CRM systems is ingested from S3 into DuckDB/Snowflake as raw tables and defining schemas and metadata.

2. **Data Transformation (dbt):**
* **Raw to staging**
  * Standardized naming conventions and cleaned textual data

  * categorical values to ensure consistency across systems

  * Removed duplicates by retaining the most recent records

  * Handled missing, null, or invalid values with defaulting and fallback logic

  * Corrected and validated date fields to ensure reliability

  * Parsed and restructured complex or composite fields for clarity

  * Unified data from multiple sources into a consistent, analytics-ready format
  

* **Staging to marts**
  * Generate surrogate keys for orders and customers.

  * Join sales data with products and customers.

  * Map sales attributes (order number, amount, quantity).

  * Integrate customer data from CRM and ERP, prioritizing CRM values.

  * Combine customer details (name, marital status, location).

  * Map key date fields (order date, shipping date, creation date).
  
**Marts:**  `dim_customers`,  `dim_products` and  `fact_sales`

3. **Orchestration (Dagster):** \
Dagster on the other hand is used to:

   * Run dbt commands

   * Track data lineage

   * Schedule jobs like `dbt build` and `docs generate`

   * Serve dashboards via `dbt docs`
   
4. **Duckdb and Snowflake DataWarehouse**

A two-tiered data warehousing strategy was adopted to balance development efficiency with production scalability:
* Duckdb Local UseCases:

  * Local testing of dbt SQL models with immediate feedback.
  * Simulating Snowflake behavior using the same SQL and macros.

  * Validating model relationships, filters, and joins before deployment.

  * Rapid iteration during transformation logic development.

  * Optional integration with tools like DBeaver for interactive querying.
  
![img.png](img.png)
_A view of the data using DBeaver_

This enables efficient model development in isolation before deploying to the production warehouse.
* **Snowflake – Production Warehouse - Provisioned using Terraform**
  * Runs production dbt models using cloud compute resources.

  * Stores cleaned, modeled data (dim_, fact_) for BI consumption.

  * Executes scheduled analytics workflows via Dagster.

  * Hosts persistent data layers for real-time dashboard querying.

  * Enables role-based access and query tagging for governance and cost tracking.
Terraform was used to provision all required infrastructure components, ensuring consistent and automated deployment of the data platform. The instructions to set up can be found [here](./infrastructure/README.md)


>[!NOTE]
>_Coming soon - still under development._

5. **Business Insights (Streamlit + LLM Queries)**

* **Streamlit Dashboards:** Interactive dashboards are created for real-time monitoring of key metrics (e.g., sales performance, inventory levels).

* **LLM Queries:** Large Language Models (LLM) with snowflakeCortex Analyst, are used to answer business questions by generating SQL queries using natural language. This provides a natural language interface for executives or team members to query the data without needing to know SQL.

## Challenges
* Because of the careful selection of tech stack, setting up everything was quite smooth. However, there were minimal typical errors such as:
  * Missing dependencies 
  * Incorrect configuration of dlt with dagster
* During Loading and transformation of the data, there were some notable syntactical errors which I listed in this file along with how I handled them.






