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