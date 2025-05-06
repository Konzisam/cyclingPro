## How to run the project

### Requirements

1. **Software Dependencies**:
   - Dependencies listed in pyproject.toml

2. **Cloud Services**:
   - **Snowflake (Optional)** 
   - **Terraform (Optional)** 
   - **AWS (S3 Bucket)** 

3. **Development Tools**:
   - **Dagster** (for orchestration)
   - **dbt** (for data transformation)
   - **DLT** (for data loading)
   - `DuckDB` (for local testing)
4. Dataset can be found here
    - Upload data to s3 using the command:
``
   
## Steps
### 1. Clone the Project
First, clone the repository that contains the project.
```
git clone https://github.com/Konzisam/cyclingPro-case-study.git
cd cyclingPro-case-study
```

### 2: Set Up Virtual Environment and Install Dependencies
Next, create a virtual environment and install the required dependencies.

```
python -m venv venv
source ven/bin/activate  # On Windows use `ven\Scripts\activate`

`pip install -e ".[dev]"`
```
When setting up the
Run `dagster project scaffold --name cyclingPro`
Run `dlt init snowflake duckdb`


If running locally with DuckDb then just start Dagster:
```
DAGSTER_HOME=$(pwd) dagster dev
```
>[!NOTE]
>dlt will create a file crm_erp_data.duckdb in the root file.


## Image

Further steps on:  **How to setup snowflake using terraform** 

View of the UI with snowflake


## Image 

```
aws s3api create-bucket --bucket cyclingPro --region us-east-1 --create-bucket-configuration LocationConstraint=us-east-1
```
---

In DuckDB, subtracting an integer (like 1) directly from a VARCHAR or DATE type without explicit casting causes a **Binder Error**. 

`LEAD(prd_start_dt)` may be returning a VARCHAR instead of a DATE, and DuckDB can't perform subtraction between a VARCHAR and an INTEGER.
```
CAST(
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 
    AS DATE
) AS prd_end_dt

```

Changes to: 
```
CAST(
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) - INTERVAL '1 day'
    AS DATE
) AS prd_end_dt
```

or even safer:

```
CAST(
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE) - INTERVAL '1 day'
    AS DATE
) AS prd_end_dt
```
---
Another problem is type casting:

```
  CASE 
    WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
  END AS sls_order_dt
```
Changes to to explicitly typecast

```
    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE TO_DATE(CAST(sls_order_dt AS STRING), 'YYYYMMDD')
    END AS sls_order_dt
```

---
`TO_DATE('20101229', 'YYYYMMDD')` is the correct function in Snowflake

`STRPTIME(CAST({{ field_name }} AS STRING), '%Y%m%d') `


This doesnt work

`WHEN 'REPLACE(cid, "-", "")' IS NULL`

but this does:

`{{ clean_and_upper("REPLACE(cid, '-', '')") }}`

Probably, attention to the quotes



