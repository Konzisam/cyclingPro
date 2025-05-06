from collections.abc import Mapping
from typing import Optional, Any
import subprocess
from dagster_dbt import dbt_assets, DbtCliResource, DbtProject, DagsterDbtTranslator
from dagster import AssetExecutionContext, op, job, Definitions, AssetKey, AssetDep
from pathlib import Path

DBT_PROJECT_PATH = Path(__file__).joinpath("..", "..", "..", "dbt").resolve()
DBT_PROFILES = Path(__file__).joinpath("..", "..", "..", "dbt").resolve()

dbt_resource = DbtCliResource(
    project_dir=DBT_PROJECT_PATH,
    profiles_dir=DBT_PROFILES,
)

dbt_project = DbtProject(project_dir=DBT_PROJECT_PATH)
dbt_project.prepare_if_dev()

class CustomizedDagsterDbtTranslator(DagsterDbtTranslator):
    def get_group_name(self, dbt_resource_props: Mapping[str, Any]) -> Optional[str]:
        asset_path = dbt_resource_props["fqn"][1:-1]
        if asset_path:
            return "_".join(asset_path)
        return "default"

    def get_asset_key(self, dbt_resource_props):
        resource_type = dbt_resource_props["resource_type"]
        name = dbt_resource_props["name"]
        if resource_type == "source":
            return AssetKey(name)
        else:
            return super().get_asset_key(dbt_resource_props)


@dbt_assets(manifest=dbt_project.manifest_path,
            dagster_dbt_translator=CustomizedDagsterDbtTranslator(),
            )

def dbt_assets_cycling_pro(context: AssetExecutionContext, dbt: DbtCliResource):
    """Runs the dbt build process as a Dagster asset"""
    yield from dbt.cli(["build"], context=context).stream()


# defs = Definitions(
#     assets=[dbt_assets_cycling_pro],
#     resources={
#         "dbt": dbt_resource,
#     },
# )

@op
def generate_dbt_docs(context: AssetExecutionContext, dbt: DbtCliResource):
    context.log.info(f"Generating dbt docs in: {dbt.project_dir}")

    result = dbt.cli(["docs", "generate"], context=context)

    for event in result.stream():
        context.log.info(event.message)

    target_path = Path(dbt.project_dir) / "target" / "index.html"
    if target_path.exists():
        context.log.info(f"Docs generated successfully at: {target_path}")
    else:
        context.log.warn(f"Docs not found at expected location: {target_path}")


@job(resource_defs={"dbt": dbt_resource})
def dbt_docs_job():
    dbt_assets_cycling_pro()  # This triggers the dbt build
    generate_dbt_docs()       # Then generates the docs

defs = Definitions(
    assets=[dbt_assets_cycling_pro],
    jobs=[dbt_docs_job],
    resources={"dbt": dbt_resource},
)


# @dbt_assets(manifest=dbt_project.manifest_path)
# def dbt_assets_cycling_pro(context: AssetExecutionContext, dbt: DbtCliResource):
#     """Runs the dbt build process as a Dagster asset"""
#     yield from dbt.cli(["build"], context=context).stream()
#
#
# defs = Definitions(
#     assets=[dbt_assets_cycling_pro,crm_cust_info],
#     resources={
#         "dbt": dbt_resource,
#     },
# )

# # Job function to include dbt docs generate
# @op
# def run_dbt_docs_generate(context, dbt: DbtCliResource):
#     """Runs dbt docs generate"""
#     result = dbt.cli(["docs", "generate"], context=context)
#
#     context.log.info("DBT Docs Generation Completed.")
#     return result
#
#
# # Op to serve DBT Docs (this will run in the background)
# @op
# def serve_dbt_docs(context):
#     """Runs dbt docs serve in the background to serve the docs"""
#     context.log.info("Starting DBT Docs server...")
#
#     # Start the 'dbt docs serve' command as a subprocess
#     process = subprocess.Popen(
#         ["dbt", "docs", "serve", "--port", "8000"],
#         cwd=DBT_PROJECT_PATH,  # Set the working directory for dbt project
#         stdout=subprocess.PIPE,
#         stderr=subprocess.PIPE,
#     )
#
#     # Log server output
#     stdout, stderr = process.communicate()
#     if process.returncode == 0:
#         context.log.info("DBT Docs server is running on http://localhost:8000")
#     else:
#         context.log.error(f"Error running dbt docs serve: {stderr.decode('utf-8')}")
#
#
# # Create a job that runs the dbt build and then generates docs
# @job
# def dbt_docs_job():
#     dbt_assets_cycling_pro()
#     run_dbt_docs_generate()
#     serve_dbt_docs()