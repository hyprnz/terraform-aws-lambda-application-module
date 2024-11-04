
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

  event_bus_name_env_var = { "INTRA_SERVICE_EVENT_BUS": aws_cloudwatch_event_bus.internal.name }
  custom_policy_required = length(var.custom_policy_document) > 0 ? true : false
  tracing_config         = var.tracking_config
  enable_active_tracing  = local.tracing_config == "Active"

  layers = concat([aws_lambda_layer_version.runtime_dependencies.arn], var.additional_layers)
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

  reserved_concurrent_executions = try(each.value.function_concurrency_limit, -1)

  layers = coalesce(each.value.enable_lambda_insights_monitoring, var.enable_lambda_insights_monitoring) ? concat([var.lambda_insights_extension_layer], local.layers) : local.layers
  tracing_config {
    mode = var.tracking_config
  }

  logging_config {
    log_format            = coalesce(each.value.log_format, "Text")
    log_group             = aws_cloudwatch_log_group.lambda_application_log_group[each.key].name
    application_log_level = each.value.application_log_level
    system_log_level      = each.value.system_log_level
  }

  environment {
    variables = merge(
      { APP_NAME = var.application_name },
      { PARAMETER_STORE_PATH = var.parameter_store_path },
      local.datastore_env_vars,
      local.event_bus_name_env_var,
      var.application_env_vars
    )
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

resource "aws_lambda_layer_version" "runtime_dependencies" {
  layer_name = var.application_name

  s3_bucket   = var.artifact_bucket
  s3_key      = var.layer_artifact_key
  description = "External modules and application shared code"

  compatible_runtimes = [var.application_runtime]
}

