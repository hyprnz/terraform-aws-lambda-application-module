module "example_lambda_applcation" {
  source = "../../"
  providers = {
    aws = aws
  }

  application_name    = "test_lambda_app"
  application_runtime = "python3.8"
  artifact_bucket     = "reuben.test.jarden.io"
  artifact_bucket_key = "market-data-usage.0.1.1.zip"
  application_memory  = 256
  application_timeout = 20
  layer_artifact_key  = "python.zip"

  lambda_functions_config = {
    event_consumer = {
      name        = "event_consumer"
      description = "event_consumer description"
      handler     = "event_consumer.handler.license_event_handler"
    },
    event_aggregator = {
      name        = "event_aggregator"
      description = "event_aggregator description"
      handler     = "event_aggregator.handler.license_aggregator_handler"
    }
  }

  internal_entrypoint_config = {
    event_aggregator = {
      name               = "EventAggregatorRule"
      description        = "Event Aggregator Rule description"
      event_pattern_json = jsonencode({ "source" : ["market-data-license-usage.created"] })
    }
  }


  application_env_vars = {
    name = "foo"
  }

  enable_datastore_module               = true
  create_dynamodb_table                 = true
  dynamodb_table_name                   = "test_lambda_app"
  dynamodb_hash_key                     = "PK"
  dynamodb_hash_key_type                = "S"
  dynamodb_range_key                    = "SK"
  dynamodb_range_key_type               = "S"
  dynamodb_autoscale_min_read_capacity  = 1
  dynamodb_autoscale_min_write_capacity = 1

  dynamodb_global_secondary_index_map = [
    {
      name            = "Inverted-Index"
      hash_key        = "SK"
      range_key       = "PK"
      write_capacity  = 1
      read_capacity   = 1
      projection_type = "KEYS_ONLY"
    }
  ]

  tags = {
    Environment = "test"
    env         = "test"
  }

}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "ap-southeast-2"
}