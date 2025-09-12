provider "aws" {
  region = "us-west-2"
}

# Common variables for all tests
variables {
  application_name    = "test-lambda-app"
  application_runtime = "python3.9"
  application_version = "v1.0.0"

  lambda_functions_config = {
    api = {
      handler    = "app.handler"
      enable_vpc = false
    }
    worker = {
      handler    = "worker.handler"
      enable_vpc = false
    }
    processor = {
      handler    = "processor.handler"
      enable_vpc = false
    }
  }

  artifact_bucket     = "test-artifact-bucket"
  artifact_bucket_key = "test-app.zip"

  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

# Test case 1: Log groups created for all lambda functions
run "verify_log_groups_for_all_functions" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_log_group.lambda_application_log_group) == 3
    error_message = "Three CloudWatch log groups should be created for three lambda functions"
  }

  assert {
    condition = alltrue([
      for key in keys(var.lambda_functions_config) :
      contains(keys(aws_cloudwatch_log_group.lambda_application_log_group), key)
    ])
    error_message = "Log groups should be created for all lambda functions"
  }
}

# Test case 2: Log group naming convention
run "verify_log_group_naming" {
  command = plan

  assert {
    condition = alltrue([
      for key, log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.name == "/aws/lambda/${var.application_name}-${key}"
    ])
    error_message = "Log group names should follow the correct naming convention"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_application_log_group["api"].name == "/aws/lambda/test-lambda-app-api"
    error_message = "API log group should have correct name"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_application_log_group["worker"].name == "/aws/lambda/test-lambda-app-worker"
    error_message = "Worker log group should have correct name"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_application_log_group["processor"].name == "/aws/lambda/test-lambda-app-processor"
    error_message = "Processor log group should have correct name"
  }
}

# Test case 3: Default retention period
run "verify_default_retention_period" {
  command = plan

  assert {
    condition = alltrue([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days == 30
    ])
    error_message = "All log groups should have default retention of 30 days"
  }
}

# Test case 4: Custom retention period
run "verify_custom_retention_period" {
  command = plan

  variables {
    aws_cloudwatch_log_group_retention_in_days = 7
  }

  assert {
    condition = alltrue([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days == 7
    ])
    error_message = "All log groups should have custom retention of 7 days"
  }
}

# Test case 5: Long retention period
run "verify_long_retention_period" {
  command = plan

  variables {
    aws_cloudwatch_log_group_retention_in_days = 365
  }

  assert {
    condition = alltrue([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days == 365
    ])
    error_message = "All log groups should have retention of 365 days"
  }
}

# Test case 6: Single lambda function configuration
run "verify_single_function_log_group" {
  command = plan

  variables {
    lambda_functions_config = {
      single = {
        handler    = "single.handler"
        enable_vpc = false
      }
    }
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.lambda_application_log_group) == 1
    error_message = "One CloudWatch log group should be created for single lambda function"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_application_log_group["single"].name == "/aws/lambda/test-lambda-app-single"
    error_message = "Single function log group should have correct name"
  }
}

# Test case 7: Lambda function with complex name
run "verify_complex_function_name_log_group" {
  command = plan

  variables {
    lambda_functions_config = {
      "complex-function-name" = {
        handler    = "complex.handler"
        enable_vpc = false
      }
    }
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_application_log_group["complex-function-name"].name == "/aws/lambda/test-lambda-app-complex-function-name"
    error_message = "Complex function name log group should have correct name"
  }
}

# Test case 8: Zero retention (never expire)
run "verify_zero_retention_period" {
  command = plan

  variables {
    aws_cloudwatch_log_group_retention_in_days = 0
  }

  assert {
    condition = alltrue([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days == 0
    ])
    error_message = "All log groups should have retention of 0 (never expire)"
  }
}

# Test case 9: Log group consistency across functions
run "verify_log_group_consistency" {
  command = plan

  assert {
    condition = alltrue([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days == 30
    ])
    error_message = "All log groups should have consistent retention period"
  }

  assert {
    condition = length(distinct([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days
    ])) == 1
    error_message = "All log groups should have the same retention period"
  }
}

# Test case 10: Log group creation with no functions (edge case)
run "verify_no_log_groups_with_no_functions" {
  command = plan

  variables {
    lambda_functions_config = {}
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.lambda_application_log_group) == 0
    error_message = "No CloudWatch log groups should be created when no lambda functions are configured"
  }
}

# Test case 11: Various retention periods
run "verify_valid_retention_periods" {
  command = plan

  variables {
    aws_cloudwatch_log_group_retention_in_days = 14
  }

  assert {
    condition = alltrue([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.retention_in_days == 14
    ])
    error_message = "All log groups should support various valid retention periods"
  }
}

# Test case 12: Log group names uniqueness
run "verify_log_group_name_uniqueness" {
  command = plan

  assert {
    condition = length(distinct([
      for log_group in aws_cloudwatch_log_group.lambda_application_log_group :
      log_group.name
    ])) == length(aws_cloudwatch_log_group.lambda_application_log_group)
    error_message = "All log group names should be unique"
  }
}
