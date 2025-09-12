provider "aws" {
  region = "us-west-2"
}

variables {
  application_name    = "test-lambda-app"
  application_runtime = "nodejs18.x"
  application_version = "1.0.0"
  artifact_bucket     = "test-artifact-bucket"
  artifact_bucket_key = "test-app.zip"

  lambda_functions_config = {
    api = {
      handler     = "api/index.handler"
      enable_vpc  = false
      description = "API handler function"
    }
    worker = {
      handler          = "worker/index.handler"
      enable_vpc       = true
      description      = "Background worker function"
      function_memory  = "512"
      function_timeout = 60
    }
  }

  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

run "lambda_functions_creation" {
  command = plan

  assert {
    condition     = length(keys(aws_lambda_function.lambda_application)) == 2
    error_message = "Should create exactly 2 Lambda functions"
  }

  assert {
    condition     = contains(keys(aws_lambda_function.lambda_application), "api")
    error_message = "Should create API Lambda function"
  }

  assert {
    condition     = contains(keys(aws_lambda_function.lambda_application), "worker")
    error_message = "Should create worker Lambda function"
  }
}

run "lambda_function_naming" {
  command = plan

  assert {
    condition     = aws_lambda_function.lambda_application["api"].function_name == "test-lambda-app-api"
    error_message = "API function should have correct naming pattern"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["worker"].function_name == "test-lambda-app-worker"
    error_message = "Worker function should have correct naming pattern"
  }
}

run "lambda_function_configuration" {
  command = plan

  assert {
    condition     = aws_lambda_function.lambda_application["api"].runtime == "nodejs18.x"
    error_message = "Functions should use specified runtime"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["api"].handler == "api/index.handler"
    error_message = "API function should have correct handler"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["worker"].handler == "worker/index.handler"
    error_message = "Worker function should have correct handler"
  }
}

run "lambda_function_memory_and_timeout" {
  command = plan

  assert {
    condition     = aws_lambda_function.lambda_application["api"].memory_size == 128
    error_message = "API function should use default memory size"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["worker"].memory_size == 512
    error_message = "Worker function should use custom memory size"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["api"].timeout == 3
    error_message = "API function should use default timeout"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["worker"].timeout == 60
    error_message = "Worker function should use custom timeout"
  }
}

run "lambda_function_vpc_configuration" {
  variables {
    vpc_subnet_ids         = ["subnet-12345", "subnet-67890"]
    vpc_security_group_ids = ["sg-abcdef"]
  }

  command = plan

  assert {
    condition     = length(aws_lambda_function.lambda_application["api"].vpc_config) == 0
    error_message = "API function should not have VPC configuration"
  }

  assert {
    condition     = length(aws_lambda_function.lambda_application["worker"].vpc_config) > 0
    error_message = "Worker function should have VPC configuration"
  }
}

run "service_catalog_application_registration" {
  command = plan

  assert {
    condition     = aws_servicecatalogappregistry_application.this.name == "test-lambda-app"
    error_message = "Service catalog application should have correct name"
  }

  assert {
    condition     = aws_servicecatalogappregistry_application.this.description == "test-lambda-app Lambda Application"
    error_message = "Service catalog application should have correct description"
  }
}

run "environment_variables_basic" {
  command = plan

  assert {
    condition     = aws_lambda_function.lambda_application["api"].environment[0].variables["APP_NAME"] == "test-lambda-app"
    error_message = "Functions should have APP_NAME environment variable"
  }

  assert {
    condition     = contains(keys(aws_lambda_function.lambda_application["api"].environment[0].variables), "PARAMETER_STORE_PATH")
    error_message = "Functions should have PARAMETER_STORE_PATH environment variable"
  }
}

run "event_bridge_creation" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_bus.internal.name == "test-lambda-app"
    error_message = "Internal event bus should be created with correct name"
  }

  assert {
    condition     = contains(keys(aws_lambda_function.lambda_application["api"].environment[0].variables), "INTRA_SERVICE_EVENT_BUS")
    error_message = "Functions should have INTRA_SERVICE_EVENT_BUS environment variable"
  }
}

run "cloudwatch_log_groups" {
  command = plan

  assert {
    condition     = length(keys(aws_cloudwatch_log_group.lambda_application_log_group)) == 2
    error_message = "Should create log groups for all Lambda functions"
  }

  assert {
    condition     = contains(keys(aws_cloudwatch_log_group.lambda_application_log_group), "api")
    error_message = "Should create log group for API function"
  }

  assert {
    condition     = contains(keys(aws_cloudwatch_log_group.lambda_application_log_group), "worker")
    error_message = "Should create log group for worker function"
  }
}

run "lambda_layer_configuration" {
  variables {
    layer_artifact_key = "layers/dependencies.zip"
  }

  command = plan

  assert {
    condition     = length(aws_lambda_layer_version.runtime_dependencies) == 1
    error_message = "Should create Lambda layer when layer_artifact_key is provided"
  }

  # TODO add override?? so test can run in plan mode
  # assert {
  #   condition     = length(aws_lambda_function.lambda_application["api"].layers) > 0
  #   error_message = "Functions should have layer attached when configured"
  # }
}

run "tracing_configuration" {
  variables {
    tracking_config = "Active"
  }

  command = plan

  assert {
    condition     = aws_lambda_function.lambda_application["api"].tracing_config[0].mode == "Active"
    error_message = "Functions should have correct tracing configuration"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["worker"].tracing_config[0].mode == "Active"
    error_message = "All functions should use same tracing configuration"
  }
}

run "custom_application_environment_variables" {
  variables {
    application_env_vars = {
      CUSTOM_VAR = "test-value"
      DEBUG_MODE = "true"
    }
  }

  command = plan

  assert {
    condition     = aws_lambda_function.lambda_application["api"].environment[0].variables["CUSTOM_VAR"] == "test-value"
    error_message = "Custom environment variables should be set"
  }

  assert {
    condition     = aws_lambda_function.lambda_application["api"].environment[0].variables["DEBUG_MODE"] == "true"
    error_message = "All custom environment variables should be set"
  }
}

# TODO add override?? so module can find buses so test can run
# run "external_event_bus_configuration" {
#   variables {
#     event_bus_config = {
#       org_event_bus_name    = "org-event-bus"
#       domain_event_bus_name = "domain-event-bus"
#     }
#   }

#   command = plan

#   assert {
#     condition     = aws_lambda_function.lambda_application["api"].environment[0].variables["ORG_EVENT_BUS"] == "org-event-bus"
#     error_message = "ORG_EVENT_BUS environment variable should be set"
#   }

#   assert {
#     condition     = aws_lambda_function.lambda_application["api"].environment[0].variables["DOMAIN_EVENT_BUS"] == "domain-event-bus"
#     error_message = "DOMAIN_EVENT_BUS environment variable should be set"
#   }
# }

run "datastore_disabled_by_default" {
  command = plan

  assert {
    condition     = !contains(keys(aws_lambda_function.lambda_application["api"].environment[0].variables), "RDS_ENDPOINT")
    error_message = "Datastore environment variables should not be set when datastore is disabled"
  }

  assert {
    condition     = !contains(keys(aws_lambda_function.lambda_application["api"].environment[0].variables), "DYNAMODB_TABLE_NAME")
    error_message = "DynamoDB environment variables should not be set when datastore is disabled"
  }

  assert {
    condition     = !contains(keys(aws_lambda_function.lambda_application["api"].environment[0].variables), "S3_BUCKET_NAME")
    error_message = "S3 environment variables should not be set when datastore is disabled"
  }
}

