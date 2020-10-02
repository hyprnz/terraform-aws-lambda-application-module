// lambda-module
//   Artifactory
//   IAM *
//   CloudWatch Logs *
//   DynamodB
//   (EventBridge Bus) -> default bus
//   EventBridge Rule *
//   EventBridge target *
//  Refactor locals that are vars

// Somehwere Else (AWS-P-L)
//   S3 notification
//     bucket-name
//     lambda-arn
//   Lambda_permission
// ->management of notifications

locals {
  lambda_functions_config = {
    event_consumer = {
      name        = "event_consumer"
      description = "event_consumer description"
      handler     = "event_consumer.handler.license_event_handler"
    },
    event_aggregator = {
      name    = "event_aggregator"
      description = "event_aggregator description"
      handler = "event_aggregator.handler.license_aggregator_handler"
    }
  }

  internal_entrypoint_config = {
    event_aggregator = {
      name               = "EventAggregatorRule"
      description        = "Event Aggregator Rule description"
      event_pattern_json = jsonencode({"source": ["market-data-license-usage.created"]})
    }
  }
}

resource "aws_lambda_function" "lambda_application" {
  for_each = local.lambda_functions_config

  s3_bucket     = var.artifact_bucket
  s3_key        = var.artifact_bucket_key
  function_name = format("%s-%s", var.application_name, each.value.name)
  description   = each.value.description
  role          = aws_iam_role.lambda_application_execution_role.arn
  handler       = each.value.handler

  runtime     = var.application_runtime
  memory_size = var.application_memory
  timeout     = var.application_timeout

  layers = [aws_lambda_layer_version.runtime_dependencies.arn]

  tags = merge(map("Name", format("%s-%s", var.application_name, each.value.name)), map("Lambda Application", var.application_name), var.tags)
}


resource "aws_lambda_layer_version" "runtime_dependencies" {
  layer_name = var.application_name

  s3_bucket   = var.artifact_bucket
  s3_key      = var.layer_artifact_key
  description = "External modules and application shared code"

  compatible_runtimes = [var.application_runtime]

}
