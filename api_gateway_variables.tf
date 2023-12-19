variable "enable_api_gateway" {
  type        = bool
  description = "Allow to create api-gateway"
  default     = false
}

variable "api_gateway_route_config" {
  type = map(object({
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/simple-calc-lambda-api.html
    operation_name = optional(string, null)
  }))
  description = "The API Gateway route configuration. The keys should be the names of the Lambda functions that triggered by the API Gateway"
  default     = {}
  nullable    = false
}

variable "api_gateway_custom_domain_zone_id" {
  type        = string
  description = "The Route 53 hosted zone id for the API gatewy custom domain. Must be provided and be valid, if the `api_gateway_custom_domain_name` is set"
  default     = ""
}

variable "api_gateway_custom_domain_name" {
  type        = string
  description = "A custom domain name for the API gateway. If not provided will use the default AWS one. Requires `api_gateway_custom_domain_zone_id` to be provided"
  default     = ""
}