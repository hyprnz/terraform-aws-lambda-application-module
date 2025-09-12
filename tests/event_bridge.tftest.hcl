provider "aws" {
  region = "us-west-2"
}

# Common variables for all tests
variables {
  application_name    = "test-lambda-app"
  application_runtime = "python3.9"
  application_version = "v1.0.0"

  lambda_functions_config = {
    processor = {
      handler    = "processor.handler"
      enable_vpc = false
    }
    scheduler = {
      handler    = "scheduler.handler"
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

# Test case 1: Internal event bus creation (always created)
run "verify_internal_event_bus_creation" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_bus.internal.name == var.application_name
    error_message = "Internal event bus should be named after the application"
  }
}

# Test case 2: No entrypoints configured (default)
run "verify_no_entrypoints_default" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_event_rule.internal_entrypoint) == 0
    error_message = "No internal event rules should be created when entrypoints are not configured"
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.lambda_internal_entrypoint) == 0
    error_message = "No internal event targets should be created when entrypoints are not configured"
  }

  assert {
    condition     = length(aws_lambda_permission.internal_entrypoints) == 0
    error_message = "No internal lambda permissions should be created when entrypoints are not configured"
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.external_entrypoint) == 0
    error_message = "No external event rules should be created when entrypoints are not configured"
  }
}

# Test case 3: Single internal entrypoint with event pattern
run "verify_single_internal_entrypoint" {
  command = plan

  variables {
    internal_entrypoint_config = {
      processor = [
        {
          name               = "process-order"
          description        = "Process new orders"
          event_pattern_json = "{\"source\":[\"myapp\"],\"detail-type\":[\"Order Created\"]}"
        }
      ]
    }
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.internal_entrypoint) == 1
    error_message = "One internal event rule should be created"
  }

  assert {
    condition = alltrue([
      for rule in aws_cloudwatch_event_rule.internal_entrypoint :
      rule.name == "test-lambda-app-process-order"
    ])
    error_message = "Event rule should have correct name format"
  }

  assert {
    condition = alltrue([
      for rule in aws_cloudwatch_event_rule.internal_entrypoint :
      rule.description == "Process new orders"
    ])
    error_message = "Event rule should have correct description"
  }

  assert {
    condition = alltrue([
      for rule in aws_cloudwatch_event_rule.internal_entrypoint :
      rule.event_pattern == "{\"detail-type\":[\"Order Created\"],\"source\":[\"myapp\"]}"
    ])
    error_message = "Event rule should have correct event pattern"
  }
}

# Test case 4: Internal entrypoint with schedule expression
run "verify_internal_entrypoint_with_schedule" {
  command = plan

  variables {
    internal_entrypoint_config = {
      scheduler = [
        {
          name                = "daily-report"
          description         = "Generate daily report"
          schedule_expression = "rate(1 day)"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for rule in aws_cloudwatch_event_rule.internal_entrypoint :
      rule.schedule_expression == "rate(1 day)"
    ])
    error_message = "Event rule should have correct schedule expression"
  }

  assert {
    condition = alltrue([
      for rule in aws_cloudwatch_event_rule.internal_entrypoint :
      rule.event_bus_name == "default"
    ])
    error_message = "Scheduled event rule should have default event bus name"
  }

  assert {
    condition = alltrue([
      for target in aws_cloudwatch_event_target.lambda_internal_entrypoint :
      target.event_bus_name == "default"
    ])
    error_message = "Scheduled event target should have default event bus name"
  }
}

# Test case 5: Multiple internal entrypoints
run "verify_multiple_internal_entrypoints" {
  command = plan

  variables {
    internal_entrypoint_config = {
      processor = [
        {
          name               = "process-order"
          description        = "Process new orders"
          event_pattern_json = "{\"source\":[\"myapp\"],\"detail-type\":[\"Order Created\"]}"
        },
        {
          name               = "process-payment"
          description        = "Process payments"
          event_pattern_json = "{\"source\":[\"myapp\"],\"detail-type\":[\"Payment Received\"]}"
        }
      ],
      scheduler = [
        {
          name                = "daily-cleanup"
          schedule_expression = "cron(0 2 * * ? *)"
        }
      ]
    }
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.internal_entrypoint) == 3
    error_message = "Three internal event rules should be created"
  }

  assert {
    condition     = length(aws_cloudwatch_event_target.lambda_internal_entrypoint) == 3
    error_message = "Three internal event targets should be created"
  }

  assert {
    condition     = length(aws_lambda_permission.internal_entrypoints) == 3
    error_message = "Three internal lambda permissions should be created"
  }
}

# Test case 6: External entrypoint configuration validation (config only)
run "verify_external_entrypoint_config" {
  command = plan

  variables {
    # Test external entrypoint config structure without referencing non-existent buses
    external_entrypoint_config = {
      processor = [
        {
          name               = "handle-external-event"
          description        = "Handle external organization events"
          event_pattern_json = "{\"source\":[\"org.service\"]}"
          event_bus_name     = "org-bus"
        }
      ]
    }
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.external_entrypoint) == 1
    error_message = "One external event rule should be created"
  }

  assert {
    condition = alltrue([
      for rule in aws_cloudwatch_event_rule.external_entrypoint :
      rule.event_bus_name == "org-bus"
    ])
    error_message = "External event rule should reference correct event bus"
  }

  assert {
    condition = alltrue([
      for target in aws_cloudwatch_event_target.lambda_external_entrypoint :
      target.event_bus_name == "org-bus"
    ])
    error_message = "External event target should reference correct event bus"
  }
}

# Test case 7: Lambda permissions configuration
run "verify_lambda_permissions" {
  command = plan

  variables {
    internal_entrypoint_config = {
      processor = [
        {
          name               = "process-order"
          event_pattern_json = "{\"source\":[\"myapp\"]}"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for perm in aws_lambda_permission.internal_entrypoints :
      perm.action == "lambda:InvokeFunction"
    ])
    error_message = "Lambda permissions should allow InvokeFunction action"
  }

  assert {
    condition = alltrue([
      for perm in aws_lambda_permission.internal_entrypoints :
      perm.principal == "events.amazonaws.com"
    ])
    error_message = "Lambda permissions should be from EventBridge principal"
  }
}

# Test case 8: Statement ID generation
run "verify_statement_id_generation" {
  command = plan

  variables {
    internal_entrypoint_config = {
      processor = [
        {
          name               = "process-order-item"
          event_pattern_json = "{\"source\":[\"myapp\"]}"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for perm in aws_lambda_permission.internal_entrypoints :
      perm.statement_id == "ProcessOrderItem"
    ])
    error_message = "Statement ID should be properly formatted from event name"
  }
}

# Test case 9: Event target configuration
run "verify_event_target_configuration" {
  command = plan

  variables {
    internal_entrypoint_config = {
      processor = [
        {
          name               = "process-order"
          event_pattern_json = "{\"source\":[\"myapp\"]}"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for target in aws_cloudwatch_event_target.lambda_internal_entrypoint :
      target.target_id == "process-order"
    ])
    error_message = "Event target should have correct target ID"
  }
}

# Test case 10: Flattened configuration logic
run "verify_flattened_configurations" {
  command = plan

  variables {
    internal_entrypoint_config = {
      processor = [
        {
          name               = "process-order"
          event_pattern_json = "{\"source\":[\"myapp\"]}"
        },
        {
          name               = "process-payment"
          event_pattern_json = "{\"source\":[\"payment\"]}"
        }
      ]
    }
  }

  assert {
    condition     = length(local.flatten_internal_entrypoint_config) == 2
    error_message = "Two flattened internal entrypoint configs should be created"
  }

  assert {
    condition = alltrue([
      for config in local.flatten_internal_entrypoint_config :
      config.function_name == "processor"
    ])
    error_message = "Flattened configs should have correct function name"
  }

  assert {
    condition = length(distinct([
      for config in local.flatten_internal_entrypoint_config : config.function_idx
    ])) == 2
    error_message = "Flattened configs should have unique function indices"
  }
}
