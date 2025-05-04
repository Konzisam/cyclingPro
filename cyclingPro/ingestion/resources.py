import os
import dlt
from dagster_aws.s3 import S3Resource
from dlt.sources.filesystem import readers
from dagster import EnvVar, ConfigurableResource

s3_resource = S3Resource(
    aws_access_key_id=EnvVar("AWS_ACCESS_KEY_ID"),
    aws_secret_access_key=EnvVar("AWS_SECRET_ACCESS_KEY"),
)

# dev_pipelines_dir = os.path.join(get_dlt_pipelines_dir(), "dev")

class DltPipelineResource(ConfigurableResource):
    pipeline_name: str
    dataset_name: str
    destination: str

    def get_pipeline(self):
        """Creates and returns a new DLT pipeline instance."""
        return dlt.pipeline(
            pipeline_name=self.pipeline_name,
            destination=self.destination,
            dataset_name=self.dataset_name,
        )

    def run_pipeline(self, file_glob: str, table_name: str, bucket_url: str):
        """Reads the CSV files and loads them into DuckDB -dev or snowflake -marts."""

        pipeline = self.get_pipeline()

        data_files = readers(bucket_url=bucket_url, file_glob=file_glob).read_csv()
        data_files.apply_hints(write_disposition="replace")
        load_info = pipeline.run(data_files.with_name(table_name))

        return load_info

dlt_resource = DltPipelineResource(
    pipeline_name="crm_erp_data",
    dataset_name="crm_erp_data_raw",
    destination="duckdb"
)

