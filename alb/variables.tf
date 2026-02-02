variable "application_loadbalancer_name" {
  type        = string
  description = "The name of the application load balancer for lambdas"
}

variable "vpc_id" {
  type        = string
  description = "The vpc_id that the application load balancer will bind to"
}

variable "subnet_ids" {
  description = "The subnet ids for application load balancer"
}

variable "zone_id" {
  type        = string
  description = "Route 53 hosted zone id"
}

variable "domain_name" {
  type        = string
  description = "The custom domain name for application load balancer"
}

variable "access_logs_bucket_name" {
  type        = string
  description = "The S3 bucket name to store the logs in. Must be provided if enable_access_logs is true."
  default     = ""
}

variable "access_logs_bucket_prefix" {
  type        = string
  description = "The S3 bucket prefix. Logs are stored in the root if not configured."
  default     = ""
}

variable "enable_access_logs" {
  type        = bool
  description = "Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified."
  default     = false
}

variable "ip_address_type" {
  type        = string
  description = <<-EOF
  Type of IP addresses used by the subnets for your load balancer. The possible values: `ipv4`, `dualstack`,
  and `dualstack-without-public-ipv4`."
  EOF
  default     = "ipv4"

  validation {
    condition     = contains(["ipv4", "dualstack", "dualstack-without-public-ipv4"], var.ip_address_type)
    error_message = "ip_address_type must be one of 'ipv4', 'dualstack', or 'dualstack-without-public-ipv4'"
  }
}

variable "create_ipv6_dns_record" {
  type        = bool
  description = "Whether to create an AAAA DNS record for the ALB when using dualstack IP address type."
  default     = false
}

variable "additional_security_group_ids" {
  type        = list(string)
  description = "Additional security group IDs to attach to the ALB"
  default     = []
}

variable "capacity_units" {
  type        = number
  description = "The minimum capacity units for the ALB"
  default     = null
}

variable "client_keep_alive" {
  type        = number
  description = "The client keep alive value in seconds"
  default     = 60
}

variable "desync_mitigation_mode" {
  type        = string
  description = "Determines how the load balancer handles requests that might pose a security risk"
  default     = "defensive"
}

variable "drop_invalid_header_fields" {
  type        = bool
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer"
  default     = true
}

variable "enable_http2" {
  type        = bool
  description = "Indicates whether HTTP/2 is enabled in application load balancers"
  default     = true
}

variable "enable_waf_fail_open" {
  type        = bool
  description = "Indicates whether to route requests to targets if they are deemed unhealthy by the load balancer health checks"
  default     = false
}

variable "idle_timeout" {
  type        = number
  description = "The time in seconds that a connection is allowed to be idle"
  default     = 60
}

variable "preserve_host_header" {
  type        = bool
  description = "Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request"
  default     = false
}

variable "xff_header_processing_mode" {
  type        = string
  description = "Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target"
  default     = "append"
}

variable "connection_logs_bucket_name" {
  type        = string
  description = "The S3 bucket name to store the connection logs in"
  default     = ""
}

variable "connection_logs_prefix" {
  type        = string
  description = "The S3 bucket prefix for connection logs"
  default     = ""
}

variable "enable_connection_logs" {
  type        = bool
  description = "Indicates whether connection logging is enabled on the load balancer"
  default     = false
}

variable "health_check_logs_logs_bucket_name" {
  type        = string
  description = "The S3 bucket name to store the health check logs in"
  default     = ""
}

variable "health_check_logs_prefix" {
  type        = string
  description = "The S3 bucket prefix for health check logs"
  default     = ""
}

variable "enable_health_check_logs" {
  type        = bool
  description = "Indicates whether health check logging is enabled on the load balancer"
  default     = false
}

variable "cors_config" {
  type = object({
    enabled           = bool
    allow_origins     = string
    allow_methods     = string
    allow_headers     = string
    expose_headers    = string
    max_age           = number
    allow_credentials = optional(bool, false)
  })
  description = "CORS configuration for the ALB, used to set up OPTIONS response"
  default = {
    enabled           = false
    allow_origins     = ""
    allow_methods     = ""
    allow_headers     = ""
    expose_headers    = ""
    max_age           = 0
  }
}

variable "ssl_policy" {
  type        = string
  description = "The SSL policy for the ALB listener"
  default     = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
}

variable "enable_routing_http_response_server" {
  type        = bool
  description = <<-EOF
  Enables you to allow or remove the HTTP response server header.  Valid values are `true` or `false`.
  EOF
  default     = false
}

variable "routing_http_response_strict_transport_security_header_value" {
  type        = string
  description = <<-EOF
  Informs browsers that the site should only be accessed using HTTPS, and that any future attempts to access it
  using HTTP should automatically be converted to HTTPS. Default values are `max-age=31536000; includeSubDomains; preload`
  consult the `Strict-Transport-Security` documentation for further details.
  EOF
  default     = "max-age=31536000; includeSubDomains;"
}

variable "routing_http_response_content_security_policy_header_value" {
  type        = string
  description = <<-EOF
  Specifies restrictions enforced by the browser to help minimize the risk of certain types of security threats.
  Values for this are extensive, and can be impactful when set, consult `Content-Security-Policy` documentation.
  EOF
  default     = ""
}

variable "routing_http_response_x_content_type_options_header_value" {
  type        = string
  description = <<-EOF
  Indicates whether the MIME types advertised in the Content-Type headers should be followed and not be changed.
  The only valid value is `nosniff`."
  EOF
  default     = ""
}

variable "routing_http_response_x_frame_options_header_value" {
  type        = string
  description = <<-EOF
  Indicates whether the browser is allowed to render a page in a frame, iframe, embed or object.
  The only valid values are `DENY`, `SAMEORIGIN`, or `ALLOW-FROM https://example.com`.
  EOF
  default     = ""
}

variable "routing_http_request_x_amzn_mtls_clientcert_serial_number_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Mtls-Clientcert-Serial-Number` HTTP request header."
  default     = ""
}

variable "routing_http_request_x_amzn_mtls_clientcert_issuer_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Mtls-Clientcert-Issuer` HTTP request header."
  default     = ""
}

variable "routing_http_request_x_amzn_mtls_clientcert_subject_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Mtls-Clientcert-Subject` HTTP request header."
  default     = ""
}

variable "routing_http_request_x_amzn_mtls_clientcert_validity_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Mtls-Clientcert-Validity` HTTP request header."
  default     = ""
}

variable "routing_http_request_x_amzn_mtls_clientcert_leaf_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Mtls-Clientcert-Leaf` HTTP request header."
  default     = ""
}

variable "routing_http_request_x_amzn_mtls_clientcert_header_name" {
  type        = string
  description = " Enables you to modify the header name of the `X-Amzn-Mtls-Clientcert HTTP` request header"
  default     = ""
}

variable "routing_http_request_x_amzn_tls_version_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Tls-Version` HTTP request header."
  default     = ""
}

variable "routing_http_request_x_amzn_tls_cipher_suite_header_name" {
  type        = string
  description = "Enables you to modify the header name of the `X-Amzn-Tls-Cipher-Suite` HTTP request header."
  default     = ""
}
