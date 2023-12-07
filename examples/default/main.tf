module "example_lambda_applcation" {
  source = "../../"
  providers = {
    aws = aws
  }

  application_name    = "test_lambda_app"
  application_runtime = "python3.8"
  application_version = "0.0.1"
  artifact_bucket     = "labda-app.stage.example.com"
  artifact_bucket_key = "0.0.1/app.zip"
  application_memory  = 256
  application_timeout = 20
  layer_artifact_key  = "0.0.1/layers.zip"

  lambda_functions_config = {
    external_endpoint_function = {
      name        = "external_endpoint_function"
      description = "external_endpoint_function description"
      handler     = "external_endpoint_function.handler.handle"
    },
    internal_endpoint_function = {
      name        = "internal_endpoint_function"
      description = "internal_endpoint_function description"
      handler     = "internal_endpoint_function.handler.handle"
    }
  }

  internal_entrypoint_config = {
    internal_endpoint_function = {
      name               = "internal_endpoint_functionRule"
      description        = "internal_endpoint_function Rule description"
      event_pattern_json = { "source" : ["internal_endpoint_event.created"] }
    }
  }


  application_env_vars = {
    name = "foo"
  }

  enable_datastore                      = true
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
      name            = "Test-Index"
      hash_key        = "HK"
      range_key       = "RK"
      write_capacity  = 1
      read_capacity   = 1
      projection_type = "KEYS_ONLY"
    }
  ]

  tags = {
    Environment = "stage"
    env         = "stage"
  }

}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-east-2"
}