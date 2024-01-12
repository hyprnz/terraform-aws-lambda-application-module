
locals {
  domain_name               = try(coalesce(var.api_gateway_custom_domain_name), null) // treat both "" and null as absent
  enable_custom_domain_name = local.domain_name == null ? false : true
  rds_env_vars = {
    RDS_DBNAME   = module.lambda_datastore.rds_db_name
    RDS_ENDPOINT = module.lambda_datastore.rds_instance_endpoint
    RDS_PASSWORD = var.rds_password
    RDS_URL      = module.lambda_datastore.rds_db_url
  }

  dynamodb_env_vars = {
    DYNAMODB_TABLE_NAME = module.lambda_datastore.dynamodb_table_name
  }

  s3_env_vars = {
    S3_BUCKET_NAME = module.lambda_datastore.s3_bucket_name
  }

  rds_env_vars_used      = var.enable_datastore && var.create_rds_instance ? local.rds_env_vars : {}
  dynamodb_env_vars_used = var.enable_datastore && var.create_dynamodb_table ? local.dynamodb_env_vars : {}
  s3_env_vars_used       = var.enable_datastore && var.create_s3_bucket ? local.s3_env_vars : {}

  datastore_env_vars = merge(local.rds_env_vars_used, local.dynamodb_env_vars_used, local.s3_env_vars_used)

  vpc_policy_required = contains(values(var.lambda_functions_config)[*].enable_vpc, true) ? true : false

  custom_policy_required = length(var.custom_policy_document) > 0 ? true : false
  tracing_config         = var.tracking_config
  enable_active_tracing  = local.tracing_config == "Active"
}


resource "aws_lambda_function" "lambda_application" {
  for_each = var.lambda_functions_config

  s3_bucket     = var.artifact_bucket
  s3_key        = var.artifact_bucket_key
  function_name = format("%s-%s", var.application_name, each.key)
  description   = each.value.description
  role          = aws_iam_role.lambda_application_execution_role.arn
  handler       = each.value.handler

  publish     = true
  runtime     = var.application_runtime
  memory_size = try(each.value.function_memory, var.application_memory)
  timeout     = try(each.value.function_timeout, var.application_timeout)

  layers = concat([aws_lambda_layer_version.runtime_dependencies.arn], var.additional_layers)
  tracing_config {
    mode = var.tracking_config
  }

  environment {
    variables = merge({ APP_NAME = var.application_name }, { PARAMETER_STORE_PATH = var.parameter_store_path }, local.datastore_env_vars, var.application_env_vars)
  }

  dynamic "vpc_config" {
    for_each = each.value.enable_vpc ? [true] : []
    content {
      subnet_ids         = var.vpc_subnet_ids
      security_group_ids = var.vpc_security_group_ids
    }
  }

  tags = merge({ Name = format("%s-%s", var.application_name, each.key) }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_lambda_alias" "lambda_application_alias" {
  for_each = var.lambda_functions_config

  name             = var.alias_name
  description      = var.alias_description
  function_name    = aws_lambda_function.lambda_application[each.key].arn
  function_version = aws_lambda_function.lambda_application[each.key].version
}

resource "aws_lambda_permission" "internal_entrypoints" {
  for_each = var.internal_entrypoint_config

  statement_id  = replace(title(each.value.name), "/-| |_/", "")
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.internal_entrypoint[each.key].arn
  qualifier     = aws_lambda_alias.lambda_application_alias[each.key].name
}

# resource "aws_lambda_permission" "external_entrypoints" {
#   for_each = local.external_entrypoint_config

#   statement_id   = replace(title(each.value.name), "/-| |_/", "")
#   action         = "lambda:InvokeFunction"
#   function_name  = aws_lambda_function.lambda_application[each.key].function_name
#   principal      = "s3.amazonaws.com"
#   source_account =
# }


resource "aws_lambda_layer_version" "runtime_dependencies" {
  layer_name = var.application_name

  s3_bucket   = var.artifact_bucket
  s3_key      = var.layer_artifact_key
  description = "External modules and application shared code"

  compatible_runtimes = [var.application_runtime]
}

