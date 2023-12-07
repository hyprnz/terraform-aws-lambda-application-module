module "example" {
  source = "../"

  providers = {
    aws = aws
  }

  artifactory_bucket_name = "lambda-app.stage.example.com"
  application_name        = "lambda-app"
  cross_account_numbers   = ["373538222530"]
  force_destroy           = true
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-west-2"
}

output "bucket_name" {
  value = module.example.bucket_name
}
