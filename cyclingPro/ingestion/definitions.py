import os
from cyclingPro.ingestion.resources import DltPipelineResource, dlt_resource
from dagster import asset, AssetExecutionContext, Definitions, define_asset_job, in_process_executor

SOURCE_CRM = "source_crm"
SOURCE_ERP = "source_erp"

FILES_AND_TABLES = [
    (f"{SOURCE_CRM}/cust_info.csv", "crm_cust_info"),
    (f"{SOURCE_CRM}/prd_info.csv", "crm_prd_info"),
    (f"{SOURCE_CRM}/sales_details.csv", "crm_sales_details"),
    (f"{SOURCE_ERP}/LOC_A101.csv", "erp_loc_a101"),
    (f"{SOURCE_ERP}/CUST_AZ12.csv", "erp_cust_az12"),
    (f"{SOURCE_ERP}/PX_CAT_G1V2.csv", "erp_px_cat_g1v2"),
]

def make_asset(file_glob: str, table_name: str):
    @asset(name=table_name, group_name="dlt_assets")
    def _asset(context: AssetExecutionContext, dlt_resource: DltPipelineResource):
        logger = context.log
        bucket_url = os.getenv("AWS_S3_BUCKET")
        logger.info(f"Reading and loading data for {table_name} from {file_glob}")
        results = dlt_resource.run_pipeline(file_glob=file_glob, table_name=table_name, bucket_url=bucket_url)
        logger.info(f"DLT pipeline execution results for {table_name}: {results}")
        return f"{table_name} loaded"

    return _asset

dlt_assets = [make_asset(file_glob, table_name) for file_glob, table_name in FILES_AND_TABLES]

dlt_job = define_asset_job(
    name="dlt_job",
    selection="*",
    executor_def=in_process_executor
)


defs = Definitions(
    assets=dlt_assets,
    resources={
        "dlt_resource": dlt_resource,
    },
    jobs=[dlt_job],
)
