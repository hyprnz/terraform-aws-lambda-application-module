terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Fetch default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create Route 53 hosted zone for custom domain
resource "aws_route53_zone" "example" {
  name = "example.com"
}

# Minimal ALB module configuration
module "alb" {
  source = "../"

  # Required variables
  application_loadbalancer_name = "example-alb"
  vpc_id                        = data.aws_vpc.default.id
  subnet_ids                    = data.aws_subnets.default.ids
  zone_id                       = aws_route53_zone.example.zone_id
  domain_name                   = aws_route53_zone.example.name

  # Optional: Configure CORS (disabled by default)
  cors_config = {
    enabled           = false
    allow_origins     = ""
    allow_methods     = ""
    allow_headers     = ""
    expose_headers    = ""
    max_age           = 0
    allow_credentials = false
  }

  # Optional: Enable logging
  enable_access_logs = false
}

# Output the ALB DNS name
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = module.alb.load_balancer_arn
}
