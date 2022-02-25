resource "aws_alb" "alb_lambda" {
  name               = var.application_loadbalancer_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_lambda_access.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = true

  access_logs {
    bucket  = var.access_logs_bucket_name
    prefix  = var.access_logs_bucket_prefix
    enabled = var.enable_access_logs
  }

  tags = merge({ Name = var.application_loadbalancer_name }, var.tags)
}