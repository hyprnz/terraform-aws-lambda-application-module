module "lamnda_applciation_artifactory_example" {
  source = "../"

  providers = {
    aws = aws
  }

  artifactory_bucket_name = "test-lambda-app.stage.example.com"
  lambda_application_name = "test-lambda-app"
  cross_account_numbers   = [12345678901]
  force_destroy           = true
}

provider "aws" {
  region = var.aws_region
}
  
variable "aws_region" {
  default = "ap-southeast-2"
}

output "bucket_name" {
  value = module.lamnda_applciation_artifactory_example.bucket_name
}
