variable "enable_api_gateway" {
  type        = bool
  description = "Allow to create api-gateway"
  default     = false
}

variable "api_gateway_route_config" {
  type = map(object({
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/simple-calc-lambda-api.html
    route          = optional(string, null)
    operation_name = optional(string, null)
    methods        = optional(set(string), ["ANY"])
  }))
  description = "The API Gateway route configuration. The keys should be the names of the Lambda functions that triggered by the API Gateway"
  default     = {}
  nullable    = false
}

variable "api_gateway_custom_domain_zone_id" {
  type        = string
  description = "The Route 53 hosted zone id for the API gateway custom domain. Must be provided and be valid, if the `api_gateway_custom_domain_name` is set"
  default     = ""
}

variable "api_gateway_custom_domain_name" {
  type        = string
  description = "A custom domain name for the API gateway. If not provided will use the default AWS one. Requires `api_gateway_custom_domain_zone_id` to be provided"
  default     = ""
}

variable "api_gateway_cors_configuration" {
  type = object({
    allow_credentials = optional(bool, null)
    allow_headers     = optional(set(string), null)
    allow_methods     = optional(set(string), null)
    allow_origins     = optional(set(string), null)
    expose_headers    = optional(set(string), null)
    max_age           = optional(number, null)
  })
  description = "Cross-origin resource sharing (CORS) configuration."
  nullable    = false
  default     = {}
}

variable "api_gateway_payload_format_version" {
  type        = string
  description = "Specifies the format of the payload sent to an integration. Required for HTTP APIs."
  default     = "1.0"

  validation {
    condition     = contains(["1.0", "2.0"], var.api_gateway_payload_format_version)
    error_message = "Valid values for api_gateway_payload_format_version are \"1.0\" or \"2.0\"."
  }
}
