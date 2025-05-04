from dagster import define_asset_job, AssetSelection

# Create a job where DBT depends on the result of DLT (the raw tables)
# dlt_and_dbt_job = define_asset_job(
#     name="dlt_and_dbt_job",
#     selection=AssetSelection.assets("dlt_pipeline")  # DLT pipeline asset (raw tables)
#     .after("dbt_assets_cycling_pro")  # DBT transformation asset
# )

dlt_job = define_asset_job(
    name="dlt_job",
    selection=AssetSelection.assets(["dlt_pipeline"])
)

dbt_job = define_asset_job(
    name="dbt_job",
    selection=AssetSelection.assets(["dbt_assets_cycling_pro"])
)