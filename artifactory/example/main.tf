module "lambda_applciation_artifactory_example" {
  source = "../"

  providers = {
    aws = aws
  }

  artifactory_bucket_name = "lambda-app.stage.example.com"
  application_name        = "lambda-app"
  cross_account_numbers   = [12345678901, 98765432109]
  force_destroy           = true
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "ap-southeast-2"
}

output "bucket_name" {
  value = module.lambda_applciation_artifactory_example.bucket_name
}
