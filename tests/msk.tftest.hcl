provider "aws" {
  region = "us-west-2"
}

# Common variables for all tests
variables {
  application_name    = "test-lambda-app"
  application_runtime = "python3.9"
  application_version = "v1.0.0"

  lambda_functions_config = {
    consumer = {
      handler    = "consumer.handler"
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

# Test case 1: MSK disabled (default)
run "verify_no_resources_when_disabled" {
  command = plan

  assert {
    condition     = length(aws_lambda_event_source_mapping.msk_event_source) == 0
    error_message = "No MSK event source mappings should be created when msk_event_source_config is empty"
  }

  assert {
    condition     = length(local.flattened_msk_event_source_configs) == 0
    error_message = "Flattened MSK configs should be empty when msk_event_source_config is empty"
  }
}

# Test case 2: Single MSK event source configuration
run "verify_single_msk_event_source" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic             = "test-topic"
          starting_position = "LATEST"
          batch_size        = 100
          enabled           = true
        }
      ]
    }
  }

  assert {
    condition     = length(aws_lambda_event_source_mapping.msk_event_source) == 1
    error_message = "One MSK event source mapping should be created"
  }

  assert {
    condition     = length(local.flattened_msk_event_source_configs) == 1
    error_message = "One flattened MSK config should be created"
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.event_source_arn == var.msk_arn
    ])
    error_message = "Event source mapping should use the provided MSK ARN"
  }
}

# Test case 3: Multiple MSK event source configurations
run "verify_multiple_msk_event_sources" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic             = "orders"
          starting_position = "LATEST"
          batch_size        = 100
          enabled           = true
        },
        {
          topic             = "payments"
          starting_position = "TRIM_HORIZON"
          batch_size        = 50
          enabled           = true
        }
      ],
      processor = [
        {
          topic             = "events"
          starting_position = "LATEST"
          batch_size        = 200
          enabled           = false
        }
      ]
    }
  }

  assert {
    condition     = length(aws_lambda_event_source_mapping.msk_event_source) == 3
    error_message = "Three MSK event source mappings should be created"
  }

  assert {
    condition     = length(local.flattened_msk_event_source_configs) == 3
    error_message = "Three flattened MSK configs should be created"
  }
}

# Test case 4: MSK event source mapping configuration
run "verify_msk_event_source_mapping_config" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic             = "test-topic"
          starting_position = "TRIM_HORIZON"
          batch_size        = 150
          enabled           = true
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      contains(mapping.topics, "test-topic")
    ])
    error_message = "Event source mapping should have correct topic"
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.starting_position == "TRIM_HORIZON"
    ])
    error_message = "Event source mapping should have correct starting position"
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.batch_size == 150
    ])
    error_message = "Event source mapping should have correct batch size"
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.enabled == true
    ])
    error_message = "Event source mapping should be enabled"
  }
}

# Test case 5: Consumer group ID generation
run "verify_consumer_group_id_generation" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic                    = "test-topic"
          consumer_group_id_prefix = "app-"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for config in local.flattened_msk_event_source_configs :
      startswith(config.consumer_group_id, sha1(join("_", ["consumer", var.msk_arn, "test-topic"])))
    ])
    error_message = "Consumer group ID should be generated correctly"
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      alltrue([
        for config in mapping.amazon_managed_kafka_event_source_config :
        startswith(config.consumer_group_id, "app-")
      ])
    ])
    error_message = "Consumer group ID should include the prefix"
  }
}

# Test case 6: Override event source ARN
run "verify_override_event_source_arn" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/default-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          event_source_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/override-msk/uuid"
          topic            = "test-topic"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.event_source_arn == "arn:aws:kafka:us-west-2:123456789012:cluster/override-msk/uuid"
    ])
    error_message = "Event source mapping should use the overridden MSK ARN"
  }

  assert {
    condition = alltrue([
      for config in local.flattened_msk_event_source_configs :
      config.event_source_arn == "arn:aws:kafka:us-west-2:123456789012:cluster/override-msk/uuid"
    ])
    error_message = "Flattened config should use the overridden MSK ARN"
  }
}

# Test case 7: Default values
run "verify_default_values" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic = "test-topic"
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.starting_position == "LATEST"
    ])
    error_message = "Default starting position should be LATEST"
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.enabled == true
    ])
    error_message = "Default enabled state should be true"
  }

  assert {
    condition = alltrue([
      for config in local.flattened_msk_event_source_configs :
      config.consumer_group_id_prefix == ""
    ])
    error_message = "Default consumer group ID prefix should be empty"
  }
}

# Test case 8: Disabled event source mapping
run "verify_disabled_event_source_mapping" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic   = "test-topic"
          enabled = false
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.enabled == false
    ])
    error_message = "Event source mapping should be disabled when enabled is false"
  }
}

# Test case 9: Null batch size handling
run "verify_null_batch_size_handling" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic      = "test-topic"
          batch_size = null
        }
      ]
    }
  }

  assert {
    condition = alltrue([
      for mapping in aws_lambda_event_source_mapping.msk_event_source :
      mapping.batch_size == null
    ])
    error_message = "Event source mapping should handle null batch size correctly"
  }
}

# Test case 10: Consumer group ID uniqueness
run "verify_consumer_group_id_uniqueness" {
  command = plan

  variables {
    msk_arn = "arn:aws:kafka:us-west-2:123456789012:cluster/test-msk/uuid"
    msk_event_source_config = {
      consumer = [
        {
          topic = "topic1"
        },
        {
          topic = "topic2"
        }
      ]
    }
  }

  assert {
    condition     = length(local.flattened_msk_event_source_configs) == 2
    error_message = "Should create two configs for different topics"
  }

  assert {
    condition = length(distinct([
      for config in local.flattened_msk_event_source_configs : config.consumer_group_id
    ])) == 2
    error_message = "Consumer group IDs should be unique for different topics"
  }
}
