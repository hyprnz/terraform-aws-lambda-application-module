provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}


data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_route53_zone" "this" {
  name = "myexample.com"
}

module "alb" {
  source = "../"

  application_loadbalancer_name = "example"
  zone_id                       = aws_route53_zone.this.id
  subnet_ids                    = data.aws_subnets.default.ids
  domain_name                   = "myexample.com"
  vpc_id                        = data.aws_vpc.default.id
  enable_custom_domain          = false
}