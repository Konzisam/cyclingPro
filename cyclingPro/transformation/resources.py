from dagster_dbt import DbtCliResource
from cyclingPro.transformation.definitions import DBT_PROJECT_PATH, DBT_PROFILES

dbt_resource = DbtCliResource(
    project_dir=DBT_PROJECT_PATH,
    profiles_dir=DBT_PROFILES,
)
