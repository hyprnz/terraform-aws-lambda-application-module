locals {
  enable_cors_response = var.cors_config.enabled ? 1 : 0
}

resource "aws_lb_listener" "alb_lambda_listener" {
  load_balancer_arn = aws_alb.alb_lambda.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate_validation.alb_route53_record_validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Page not found"
      status_code  = "404"
    }
  }

  routing_http_response_server_enabled = var.enable_routing_http_response_server

  routing_http_response_strict_transport_security_header_value          = var.routing_http_response_strict_transport_security_header_value
  routing_http_response_content_security_policy_header_value            = var.routing_http_response_content_security_policy_header_value
  routing_http_response_x_content_type_options_header_value             = var.routing_http_response_x_content_type_options_header_value
  routing_http_response_x_frame_options_header_value                    = var.routing_http_response_x_frame_options_header_value
  routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name = var.routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name
  routing_http_request_x_amzn_mtls_clientcert_issuer_header_name        = var.routing_http_request_x_amzn_mtls_clientcert_issuer_header_name
  routing_http_request_x_amzn_mtls_clientcert_subject_header_name       = var.routing_http_request_x_amzn_mtls_clientcert_subject_header_name
  routing_http_request_x_amzn_mtls_clientcert_validity_header_name      = var.routing_http_request_x_amzn_mtls_clientcert_validity_header_name
  routing_http_request_x_amzn_mtls_clientcert_leaf_header_name          = var.routing_http_request_x_amzn_mtls_clientcert_leaf_header_name
  routing_http_request_x_amzn_mtls_clientcert_header_name               = var.routing_http_request_x_amzn_mtls_clientcert_header_name
  routing_http_request_x_amzn_tls_version_header_name                   = var.routing_http_request_x_amzn_tls_version_header_name
  routing_http_request_x_amzn_tls_cipher_suite_header_name              = var.routing_http_request_x_amzn_tls_cipher_suite_header_name

  routing_http_response_access_control_allow_origin_header_value      = var.cors_config.enabled ? var.cors_config.allow_origins : ""
  routing_http_response_access_control_allow_methods_header_value     = var.cors_config.enabled ? var.cors_config.allow_methods : ""
  routing_http_response_access_control_allow_headers_header_value     = var.cors_config.enabled ? var.cors_config.allow_headers : ""
  routing_http_response_access_control_expose_headers_header_value    = var.cors_config.enabled ? var.cors_config.expose_headers : ""
  routing_http_response_access_control_allow_credentials_header_value = (var.cors_config.enabled &&
                                                                          var.cors_config.allow_origins != "*" &&
                                                                          var.cors_config.allow_credentials) ? true : null
  routing_http_response_access_control_max_age_header_value           = var.cors_config.enabled ? var.cors_config.max_age : ""
}

resource "aws_lb_listener_rule" "cors_rule" {
  count        = local.enable_cors_response
  listener_arn = aws_lb_listener.alb_lambda_listener.arn
  priority     = 1

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      status_code  = "204"
    }
  }

  condition {
    http_request_method {
      values = ["OPTIONS"]
    }
  }
}
