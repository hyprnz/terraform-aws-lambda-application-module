module "example_lambda_applcation" {
  source = "../../"
  providers = {
    aws = aws
  }

  application_name    = var.application_name
  application_runtime = var.application_runtime
  artifact_bucket     = var.artifact_bucket
  artifact_bucket_key = var.artifact_bucket_key
  application_memory  = var.application_memory
  application_timeout = var.application_timeout
  layer_artifact_key  = var.layer_artifact_key

  lambda_functions_config = var.lambda_functions_config

  internal_entrypoint_config = var.internal_entrypoint_config

  application_env_vars = var.application_env_vars
  enable_datastore_module               = var.enable_datastore_module
  create_dynamodb_table                 = var.create_dynamodb_table
  dynamodb_table_name                   = var.dynamodb_table_name
  dynamodb_hash_key                     = var.dynamodb_hash_key
  dynamodb_hash_key_type                = var.dynamodb_hash_key_type
  dynamodb_range_key                    = var.dynamodb_range_key
  dynamodb_range_key_type               = var.dynamodb_range_key_type
  dynamodb_autoscale_min_read_capacity  =  var.dynamodb_autoscale_min_read_capacity
  dynamodb_autoscale_min_write_capacity =  var.dynamodb_autoscale_max_write_capacity

  dynamodb_global_secondary_index_map = var.dynamodb_global_secondary_index_map
  tags = var.tags
  ssm_kms_key_arn = var.ssm_kms_key_arn
  application_version = var.application_version
  alias_name = var.alias_name
  zone_id = var.zone_id
  parameter_store_path= var.parameter_store_path
  domain_name = var.domain_name
  publish = var.publish
  enable_api_gateway  = var.enable_api_gateway
}

provider "aws" {
  region = var.aws_region
}