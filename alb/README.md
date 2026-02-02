<!-- BEGIN_TF_DOCS -->
# Application Load Balancer Module

## Description

This module provides a flexible, opinionated Application Load Balancer (ALB) for Lambda applications with HTTPS support. It enables HTTPS API requests with path-based routing to direct traffic to the correct Lambda Application service or function.

The module includes comprehensive support for:
- HTTPS listener configuration with customisable SSL policies
- Cross-Origin Resource Sharing (CORS) support for preflight requests
- Path-based routing for Lambda targets
- Comprehensive logging (access, connection, and health check logs)
- Security configurations including custom headers, WAF integration, and mTLS support
- X-Forwarded-For header processing and host header preservation

A custom domain name and Route 53 hosted zone are required to use this module, as AWS-provided SSL certificates are not available for ALB listeners.

## Usage

```hcl
module "alb" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//alb?ref=<some-tag>"

  application_loadbalancer_name = "my-app-alb"
  vpc_id                        = "vpc-12345678"
  subnet_ids                    = ["subnet-1", "subnet-2"]
  zone_id                       = "Z1234567890ABC"
  domain_name                   = "api.example.com"
  ssl_policy                    = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  cors_config = {
    enabled           = true
    allow_origins     = "*"
    allow_methods     = "GET,POST,OPTIONS"
    allow_headers     = "*"
    expose_headers    = "Content-Length"
    max_age           = 3600
    allow_credentials = false
  }

  enable_access_logs      = true
  access_logs_bucket_name = "my-app-logs"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 6.0.0, <7.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 6.0.0, <7.0.0 |

## Modules

No modules.

## Resources

- `aws_alb.alb_lambda`
- `aws_lb_listener.alb_lambda_listener`
- `aws_lb_listener_rule.alb_lambda_listener_rule`
- `aws_security_group.alb_lambda_access`
- `aws_acm_certificate.alb_route53_record`
- `aws_acm_certificate_validation.alb_route53_record_validation`
- `aws_route53_record.alb_route53_record`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_loadbalancer_name | The name of the application load balancer for lambdas | `string` | n/a | yes |
| domain_name | The custom domain name for application load balancer | `string` | n/a | yes |
| subnet_ids | The subnet IDs for application load balancer | `list(string)` | n/a | yes |
| vpc_id | The VPC ID that the application load balancer will bind to | `string` | n/a | yes |
| zone_id | Route 53 hosted zone ID | `string` | n/a | yes |
| access_logs_bucket_name | The S3 bucket name to store access logs. Must be provided if enable_access_logs is true. | `string` | `""` | no |
| access_logs_bucket_prefix | The S3 bucket prefix for access logs. Logs are stored in the root if not configured. | `string` | `""` | no |
| additional_security_group_ids | Additional security group IDs to attach to the ALB | `list(string)` | `[]` | no |
| capacity_units | The minimum capacity units for the ALB | `number` | `null` | no |
| client_keep_alive | The client keep-alive value in seconds | `number` | `60` | no |
| connection_logs_bucket_name | The S3 bucket name to store connection logs | `string` | `""` | no |
| connection_logs_prefix | The S3 bucket prefix for connection logs | `string` | `""` | no |
| cors_config | CORS configuration for the ALB | `object({enabled = bool, allow_origins = string, allow_methods = string, allow_headers = string, expose_headers = string, max_age = number, allow_credentials = bool})` | `{enabled = false, allow_origins = "", allow_methods = "", allow_headers = "", expose_headers = "", max_age = 0, allow_credentials = false}` | no |
| desync_mitigation_mode | Determines how the load balancer handles requests that might pose a security risk | `string` | `"defensive"` | no |
| drop_invalid_header_fields | Whether HTTP headers with invalid header fields are removed by the load balancer | `bool` | `true` | no |
| enable_access_logs | Boolean to enable/disable access logs | `bool` | `false` | no |
| enable_connection_logs | Whether connection logging is enabled on the load balancer | `bool` | `false` | no |
| enable_health_check_logs | Whether health check logging is enabled on the load balancer | `bool` | `false` | no |
| enable_http2 | Whether HTTP/2 is enabled in application load balancers | `bool` | `true` | no |
| enable_waf_fail_open | Whether to route requests to targets if they are deemed unhealthy by the load balancer health checks | `bool` | `false` | no |
| health_check_logs_logs_bucket_name | The S3 bucket name to store health check logs | `string` | `""` | no |
| health_check_logs_prefix | The S3 bucket prefix for health check logs | `string` | `""` | no |
| idle_timeout | The time in seconds that a connection is allowed to be idle | `number` | `60` | no |
| ip_address_type | Type of IP addresses used by the subnets for your load balancer | `string` | `"ipv4"` | no |
| preserve_host_header | Whether the Application Load Balancer should preserve the Host header in the HTTP request | `bool` | `false` | no |
| routing_http_request_x_amzn_mtls_clientcert_header_name | The name of the header for mTLS client certificate | `string` | `""` | no |
| routing_http_request_x_amzn_mtls_clientcert_issuer_header_name | The name of the header for mTLS client certificate issuer | `string` | `""` | no |
| routing_http_request_x_amzn_mtls_clientcert_leaf_header_name | The name of the header for mTLS client certificate leaf | `string` | `""` | no |
| routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name | The name of the header for mTLS client certificate serial number | `string` | `""` | no |
| routing_http_request_x_amzn_mtls_clientcert_subject_header_name | The name of the header for mTLS client certificate subject | `string` | `""` | no |
| routing_http_request_x_amzn_mtls_clientcert_validity_header_name | The name of the header for mTLS client certificate validity | `string` | `""` | no |
| routing_http_request_x_amzn_tls_cipher_suite_header_name | The name of the header for TLS cipher suite | `string` | `""` | no |
| routing_http_request_x_amzn_tls_version_header_name | The name of the header for TLS version | `string` | `""` | no |
| routing_http_response_content_security_policy_header_value | The value of the Content-Security-Policy header | `string` | `""` | no |
| routing_http_response_strict_transport_security_header_value | The value of the Strict-Transport-Security header | `string` | `""` | no |
| routing_http_response_x_content_type_options_header_value | The value of the X-Content-Type-Options header | `string` | `""` | no |
| routing_http_response_x_frame_options_header_value | The value of the X-Frame-Options header | `string` | `""` | no |
| ssl_policy | The SSL policy for the ALB listener | `string` | `"ELBSecurityPolicy-TLS-1-2-Ext-2018-06"` | no |
| xff_header_processing_mode | How the load balancer modifies the X-Forwarded-For header in the HTTP request | `string` | `"append"` | no |
| enable_routing_http_response_server | Whether to enable routing HTTP response server | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn_suffix | The ARN suffix for use with CloudWatch Metrics |
| dns_name | The DNS name of the load balancer |
| load_balancer_arn | The ARN of the load balancer |
| load_balancer_id | The ID of the load balancer |
| ip_address_type | The IP address type of the load balancer |
| security_groups | The security groups assigned to the load balancer |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider |
| vpc_id | The VPC ID of the load balancer |
| zone_id | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record) |

<br/>

---

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](../LICENSE) for full details.

```text
Copyright 2020 Hypr NZ

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Copyright &copy; 2020 [Hypr NZ](https://www.hypr.nz/)
<!-- END_TF_DOCS -->
