module "example_lambda_applcation" {
  source = "../../"
  providers = {
    aws = aws
  }

  application_name    = "service-env-example-com"
  application_runtime = "python3.8"
  application_version = "0.0.1"
  artifact_bucket     = "labda-app.env.example.com"
  artifact_bucket_key = "0.0.1/app.zip"
  application_memory  = 256
  application_timeout = 20
  layer_artifact_key  = "0.0.1/layers.zip"

  parameter_store_path = "/service/env/environment/"

  lambda_functions_config = {
    ext-function = {
      name        = "ext-function"
      description = "external endpoint function description"
      handler     = "external_endpoint_function.handler.handle"
      enable_vpc  = false
    },
    int-function = {
      name        = "int-function"
      description = "internal endpoint function description"
      handler     = "internal_endpoint_function.handler.handle"
      enable_vpc  = false
    }
  }

  internal_entrypoint_config = {
    int-function = {
      name               = "int-function-rule"
      description        = "internal endpoint function Rule description"
      event_pattern_json = { "source" : ["internal_endpoint_event.created"] }
    }
  }

  enable_api_gateway       = true
  api_gateway_route_config = {
      ext-function = {
      operation_name = "service:ext-function"
    }
  }

  application_env_vars = {
    name = "foo"
  }

  enable_datastore                      = true
  create_dynamodb_table                 = true
  dynamodb_table_name                   = "LA-service-env-example-com"
  dynamodb_hash_key                     = "PK"
  dynamodb_hash_key_type                = "S"
  dynamodb_range_key                    = "SK"
  dynamodb_range_key_type               = "S"
  dynamodb_autoscale_min_read_capacity  = 1
  dynamodb_autoscale_min_write_capacity = 1

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
