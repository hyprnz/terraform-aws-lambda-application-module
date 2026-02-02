resource "aws_alb" "alb_lambda" {
  name               = var.application_loadbalancer_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = concat([aws_security_group.alb_lambda_access.id], var.additional_security_group_ids)
  subnets            = var.subnet_ids

  dynamic "minimum_load_balancer_capacity" {
    for_each = var.capacity_units != null ? [1] : []
    content {
      capacity_units = var.capacity_units
    }
  }

  enable_deletion_protection = true

  ip_address_type            = var.ip_address_type
  client_keep_alive          = var.client_keep_alive
  desync_mitigation_mode     = var.desync_mitigation_mode
  drop_invalid_header_fields = var.drop_invalid_header_fields
  enable_http2               = var.enable_http2
  enable_waf_fail_open       = var.enable_waf_fail_open
  idle_timeout               = var.idle_timeout
  preserve_host_header       = var.preserve_host_header
  xff_header_processing_mode = var.xff_header_processing_mode

  access_logs {
    bucket  = var.access_logs_bucket_name
    prefix  = var.access_logs_bucket_prefix
    enabled = var.enable_access_logs
  }

  connection_logs {
    bucket  = var.connection_logs_bucket_name
    prefix  = var.connection_logs_prefix
    enabled = var.enable_connection_logs
  }

  health_check_logs {
    bucket  = var.health_check_logs_logs_bucket_name
    prefix  = var.health_check_logs_prefix
    enabled = var.enable_health_check_logs
  }

}
