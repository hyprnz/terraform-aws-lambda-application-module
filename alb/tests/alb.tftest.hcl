provider "aws" {
  region = "us-west-2"
}

# Common variables for all tests
variables {
  application_loadbalancer_name = "test-lambda-alb"
  vpc_id                        = "vpc-12345678"
  subnet_ids                    = ["subnet-1", "subnet-2"]
  zone_id                       = "Z1234567890ABC"
  domain_name                   = "api.example.com"
  ssl_policy                    = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  cors_config = {
    enabled           = false
    allow_origins     = ""
    allow_methods     = ""
    allow_headers     = ""
    expose_headers    = ""
    max_age           = 0
    allow_credentials = false
  }

  enable_access_logs  = false
  enable_connection_logs = false
  enable_health_check_logs = false
}

# Test case 1: Basic ALB creation
run "verify_alb_name" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.name == var.application_loadbalancer_name
    error_message = "ALB name does not match expected value"
  }
}

run "verify_alb_type" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.load_balancer_type == "application"
    error_message = "ALB type should be application"
  }
}

run "verify_alb_is_not_internal" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.internal == false
    error_message = "ALB should be internet-facing"
  }
}

run "verify_alb_deletion_protection" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.enable_deletion_protection == true
    error_message = "ALB deletion protection should be enabled"
  }
}

# Test case 2: IP address configuration
run "verify_default_ip_address_type" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.ip_address_type == "ipv4"
    error_message = "Default IP address type should be ipv4"
  }
}

run "verify_dualstack_ip_address_type" {
  command = plan

  variables {
    ip_address_type = "dualstack"
  }

  assert {
    condition     = aws_alb.alb_lambda.ip_address_type == "dualstack"
    error_message = "IP address type should be dualstack when specified"
  }
}

# Test case 3: HTTP/2 and protocol configuration
run "verify_http2_enabled_by_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.enable_http2 == true
    error_message = "HTTP/2 should be enabled by default"
  }
}

run "verify_http2_can_be_disabled" {
  command = plan

  variables {
    enable_http2 = false
  }

  assert {
    condition     = aws_alb.alb_lambda.enable_http2 == false
    error_message = "HTTP/2 should be disabled when specified"
  }
}

# Test case 4: Security headers configuration
run "verify_desync_mitigation_mode" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.desync_mitigation_mode == "defensive"
    error_message = "Default desync mitigation mode should be defensive"
  }
}

run "verify_drop_invalid_header_fields" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.drop_invalid_header_fields == true
    error_message = "Invalid header fields should be dropped by default"
  }
}

# Test case 5: Access logs configuration
run "verify_access_logs_disabled_by_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.access_logs[0].enabled == false
    error_message = "Access logs should be disabled by default"
  }
}

run "verify_access_logs_enabled" {
  command = plan

  variables {
    enable_access_logs      = true
    access_logs_bucket_name = "test-access-logs-bucket"
    access_logs_bucket_prefix = "alb-logs"
  }

  assert {
    condition     = aws_alb.alb_lambda.access_logs[0].enabled == true
    error_message = "Access logs should be enabled when specified"
  }
}

run "verify_access_logs_bucket_configuration" {
  command = plan

  variables {
    enable_access_logs      = true
    access_logs_bucket_name = "test-access-logs-bucket"
    access_logs_bucket_prefix = "alb-logs"
  }

  assert {
    condition     = aws_alb.alb_lambda.access_logs[0].bucket == "test-access-logs-bucket"
    error_message = "Access logs bucket name should match specified value"
  }
}

run "verify_access_logs_prefix" {
  command = plan

  variables {
    enable_access_logs         = true
    access_logs_bucket_name    = "test-access-logs-bucket"
    access_logs_bucket_prefix  = "alb-logs"
  }

  assert {
    condition     = aws_alb.alb_lambda.access_logs[0].prefix == "alb-logs"
    error_message = "Access logs prefix should match specified value"
  }
}

# Test case 6: Connection logs configuration
run "verify_connection_logs_disabled_by_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.connection_logs[0].enabled == false
    error_message = "Connection logs should be disabled by default"
  }
}

run "verify_connection_logs_enabled" {
  command = plan

  variables {
    enable_connection_logs      = true
    connection_logs_bucket_name = "test-connection-logs-bucket"
    connection_logs_prefix      = "connection-logs"
  }

  assert {
    condition     = aws_alb.alb_lambda.connection_logs[0].enabled == true
    error_message = "Connection logs should be enabled when specified"
  }
}

# Test case 7: Health check logs configuration
run "verify_health_check_logs_disabled_by_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.health_check_logs[0].enabled == false
    error_message = "Health check logs should be disabled by default"
  }
}

run "verify_health_check_logs_enabled" {
  command = plan

  variables {
    enable_health_check_logs         = true
    health_check_logs_logs_bucket_name = "test-hc-logs-bucket"
    health_check_logs_prefix         = "health-check-logs"
  }

  assert {
    condition     = aws_alb.alb_lambda.health_check_logs[0].enabled == true
    error_message = "Health check logs should be enabled when specified"
  }
}

# Test case 8: Listener creation
run "verify_listener_exists" {
  command = plan

  assert {
    condition     = aws_lb_listener.alb_lambda_listener.port == 443
    error_message = "Listener should be created on port 443"
  }
}

run "verify_listener_protocol" {
  command = plan

  assert {
    condition     = aws_lb_listener.alb_lambda_listener.protocol == "HTTPS"
    error_message = "Listener protocol should be HTTPS"
  }
}

run "verify_listener_default_action" {
  command = plan

  assert {
    condition     = aws_lb_listener.alb_lambda_listener.default_action[0].type == "fixed-response"
    error_message = "Listener default action type should be fixed-response"
  }
}

run "verify_listener_default_action_returns_404" {
  command = plan

  assert {
    condition     = aws_lb_listener.alb_lambda_listener.default_action[0].fixed_response[0].status_code == "404"
    error_message = "Listener default action should return 404"
  }
}

# Test case 9: CORS listener rule
run "verify_cors_rule_disabled_by_default" {
  command = plan

  assert {
    condition     = length(aws_lb_listener_rule.cors_rule) == 0
    error_message = "CORS listener rule should not be created when CORS is disabled"
  }
}

run "verify_cors_rule_enabled" {
  command = plan

  variables {
    cors_config = {
      enabled           = true
      allow_origins     = "*"
      allow_methods     = "GET,POST,OPTIONS"
      allow_headers     = "*"
      expose_headers    = "Content-Length"
      max_age           = 3600
      allow_credentials = false
    }
  }

  assert {
    condition     = length(aws_lb_listener_rule.cors_rule) == 1
    error_message = "CORS listener rule should be created when CORS is enabled"
  }
}

run "verify_cors_rule_handles_options_method" {
  command = plan

  variables {
    cors_config = {
      enabled           = true
      allow_origins     = "*"
      allow_methods     = "GET,POST,OPTIONS"
      allow_headers     = "*"
      expose_headers    = "Content-Length"
      max_age           = 3600
      allow_credentials = false
    }
  }

  assert {
    condition = alltrue([
      for rule in aws_lb_listener_rule.cors_rule :
      alltrue([
        for condition in rule.condition :
        contains(tolist(condition.http_request_method[0].values), "OPTIONS")
      ])
    ])
    error_message = "CORS listener rule should handle OPTIONS method"
  }
}

run "verify_cors_rule_returns_204" {
  command = plan

  variables {
    cors_config = {
      enabled           = true
      allow_origins     = "*"
      allow_methods     = "GET,POST,OPTIONS"
      allow_headers     = "*"
      expose_headers    = "Content-Length"
      max_age           = 3600
      allow_credentials = false
    }
  }

  assert {
    condition = alltrue([
      for rule in aws_lb_listener_rule.cors_rule :
      rule.action[0].fixed_response[0].status_code == "204"
    ])
    error_message = "CORS listener rule should return 204 status code"
  }
}

# Test case 10: Capacity units
run "verify_capacity_units_not_set_by_default" {
  command = plan

  assert {
    condition     = length(aws_alb.alb_lambda.minimum_load_balancer_capacity) == 0
    error_message = "Minimum load balancer capacity should not be set by default"
  }
}

run "verify_capacity_units_custom" {
  command = plan

  variables {
    capacity_units = 10
  }

  assert {
    condition     = aws_alb.alb_lambda.minimum_load_balancer_capacity[0].capacity_units == 10
    error_message = "Capacity units should match specified value"
  }
}

# Test case 11: Timeout configuration
run "verify_default_idle_timeout" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.idle_timeout == 60
    error_message = "Default idle timeout should be 60 seconds"
  }
}

run "verify_custom_idle_timeout" {
  command = plan

  variables {
    idle_timeout = 120
  }

  assert {
    condition     = aws_alb.alb_lambda.idle_timeout == 120
    error_message = "Idle timeout should match specified value"
  }
}

run "verify_default_client_keep_alive" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.client_keep_alive == 60
    error_message = "Default client keep-alive should be 60 seconds"
  }
}

# Test case 12: Custom routing headers
run "verify_routing_headers_can_be_customized" {
  command = plan

  variables {
    routing_http_request_x_amzn_tls_version_header_name = "X-Custom-TLS-Version"
    routing_http_request_x_amzn_tls_cipher_suite_header_name = "X-Custom-Cipher-Suite"
  }

  assert {
    condition = (
      aws_lb_listener.alb_lambda_listener.routing_http_request_x_amzn_tls_version_header_name == "X-Custom-TLS-Version" &&
      aws_lb_listener.alb_lambda_listener.routing_http_request_x_amzn_tls_cipher_suite_header_name == "X-Custom-Cipher-Suite"
    )
    error_message = "Routing headers should be customizable"
  }
}

# Test case 13: Security response headers
run "verify_security_headers_can_be_set" {
  command = plan

  variables {
    routing_http_response_strict_transport_security_header_value = "max-age=31536000; includeSubDomains"
    routing_http_response_x_content_type_options_header_value = "nosniff"
    routing_http_response_x_frame_options_header_value = "DENY"
  }

  assert {
    condition = (
      aws_lb_listener.alb_lambda_listener.routing_http_response_strict_transport_security_header_value == "max-age=31536000; includeSubDomains" &&
      aws_lb_listener.alb_lambda_listener.routing_http_response_x_content_type_options_header_value == "nosniff" &&
      aws_lb_listener.alb_lambda_listener.routing_http_response_x_frame_options_header_value == "DENY"
    )
    error_message = "Security headers should be configurable"
  }
}

# Test case 14: mTLS certificate headers
run "verify_mtls_headers_can_be_customized" {
  command = plan

  variables {
    routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = "X-Custom-Cert-Serial"
    routing_http_request_x_amzn_mtls_clientcert_issuer_header_name = "X-Custom-Cert-Issuer"
    routing_http_request_x_amzn_mtls_clientcert_subject_header_name = "X-Custom-Cert-Subject"
  }

  assert {
    condition = (
      aws_lb_listener.alb_lambda_listener.routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name == "X-Custom-Cert-Serial" &&
      aws_lb_listener.alb_lambda_listener.routing_http_request_x_amzn_mtls_clientcert_issuer_header_name == "X-Custom-Cert-Issuer" &&
      aws_lb_listener.alb_lambda_listener.routing_http_request_x_amzn_mtls_clientcert_subject_header_name == "X-Custom-Cert-Subject"
    )
    error_message = "mTLS certificate headers should be customizable"
  }
}

# Test case 15: SSL policy configuration
run "verify_ssl_policy_default" {
  command = plan

  assert {
    condition     = aws_lb_listener.alb_lambda_listener.ssl_policy == "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
    error_message = "Default SSL policy should be ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  }
}

run "verify_ssl_policy_custom" {
  command = plan

  variables {
    ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  }

  assert {
    condition     = aws_lb_listener.alb_lambda_listener.ssl_policy == "ELBSecurityPolicy-TLS-1-2-2017-01"
    error_message = "SSL policy should match specified value"
  }
}

# Test case 16: WAF integration
run "verify_waf_fail_open_disabled_by_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.enable_waf_fail_open == false
    error_message = "WAF fail open should be disabled by default"
  }
}

run "verify_waf_fail_open_can_be_enabled" {
  command = plan

  variables {
    enable_waf_fail_open = true
  }

  assert {
    condition     = aws_alb.alb_lambda.enable_waf_fail_open == true
    error_message = "WAF fail open should be enabled when specified"
  }
}

# Test case 17: Host header preservation
run "verify_preserve_host_header_disabled_by_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.preserve_host_header == false
    error_message = "Host header preservation should be disabled by default"
  }
}

run "verify_preserve_host_header_can_be_enabled" {
  command = plan

  variables {
    preserve_host_header = true
  }

  assert {
    condition     = aws_alb.alb_lambda.preserve_host_header == true
    error_message = "Host header preservation should be enabled when specified"
  }
}

# Test case 18: X-Forwarded-For header processing
run "verify_xff_header_processing_default" {
  command = plan

  assert {
    condition     = aws_alb.alb_lambda.xff_header_processing_mode == "append"
    error_message = "Default X-Forwarded-For header processing should be append"
  }
}

run "verify_xff_header_processing_custom" {
  command = plan

  variables {
    xff_header_processing_mode = "preserve"
  }

  assert {
    condition     = aws_alb.alb_lambda.xff_header_processing_mode == "preserve"
    error_message = "X-Forwarded-For header processing mode should match specified value"
  }
}
