terraform {
  backend "s3" {
    bucket         = "car-predictor"
    key            = "terraform-backend/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "snowflake-terraform-lock"
  }

  required_providers {
    snowflake = {
      source = "Snowflakedb/snowflake"
    }
  }
}

provider "snowflake" {
  organization_name = var.SNOWFLAKE_ORGANIZATION
  account_name      = var.SNOWFLAKE_ACCOUNT
  user              = var.SNOWFLAKE_USER
  authenticator     = "SNOWFLAKE_JWT"
  private_key = file(var.SNOWFLAKE_PRIVATE_KEY_PATH)
}

resource "snowflake_database" "cycling_pro_db" {
  name = var.DATABASE
}

resource "snowflake_warehouse" "cycling_pro_wh" {
  name                      = "cycling_pro_wh"
  warehouse_type            = "STANDARD"
  warehouse_size            = "XSMALL"
  max_cluster_count         = 1
  min_cluster_count         = 1
  auto_suspend              = 60
  auto_resume               = true
  enable_query_acceleration = false
  initially_suspended       = true
}


