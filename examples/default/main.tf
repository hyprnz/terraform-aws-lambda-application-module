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