variable "application_name" {
  type        = string
  description = "Repo name of the lambda application."
}

variable "application_runtime" {
  type        = string
  description = "Lambda runtime for the application."
}

variable "application_version" {
  type        = string
  description = "Version of the function(s) deployed for the application."
}

variable "lambda_functions_config" {
  type        = map(any)
  description = "Map of functions and associated configurations."
}

variable "lambda_alb_config" {
  type        = map(string)
  description = "Contains entry point lambda function key"
  default     = {}
}

variable "internal_entrypoint_config" {
  type        = map(any)
  description = "Map of configurations of internal entrypoints."
}
variable "alb_lambda_listener_arn" {
  type        = string
  description = "Listener ARN of ALB"
  default     = ""
}

variable "artifact_bucket" {
  type        = string
  description = "Bucket that stores function artifacts. Includes layer dependencies."
}

variable "artifact_bucket_key" {
  type        = string
  description = "File name key of the artifact to load."
}

variable "application_env_vars" {
  type        = map(any)
  description = "Map of environment variables required by any function in the application."
  default     = {}
}

variable "application_memory" {
  type        = number
  description = "Memory allocated to all functions in the application. Defaults to `128`."
  default     = 128
}

variable "application_timeout" {
  type        = number
  description = "Timeout in seconds for all functions in the application. Defaults to `3`."
  default     = 3
}

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the Lambda function"
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs associated with the Lambda function"
  default     = []
}

variable "layer_artifact_key" {
  type        = string
  description = "File name key of the layer artifact to load."
  default     = ""
}

variable "aws_cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "The retention period in days of all log group created for each function. Defaults to `30`."
  default     = 30
}

variable "enable_api_gateway" {
  type        = bool
  description = "Allow to create api-gateway"
  default     = false
}

variable "zone_id" {
  type        = string
  description = "Route 53 hosted zone id"
  default     = ""
}

variable "domain_name" {
  type        = string
  description = "The custom domain name for api gateway that points to lambda application"
  default     = ""
}

variable "parameter_store_path" {
  type        = string
  description = "SSM parameter path"
  default     = ""
}

variable "ssm_kms_key_arn" {
  type        = string
  description = "Either he customer managed KMS or AWS manages key arn used for encrypting `SecureSting` parameters"
  default     = ""
}

variable "alias_name" {
  type        = string
  description = "Name of the alias being created"
  default     = ""
}

variable "alias_description" {
  type        = string
  description = "Name of the alias being created"
  default     = ""
}

variable "custom_policy_document" {
  type        = string
  description = "A valid policy json string that defines additional actions required by the execution role of the Lambda function"
  default     = ""
}

variable "custom_policy_description" {
  type        = string
  description = "Allows to override the custom Lambda policy's description"
  default     = ""
}

variable "additional_layers" {
  type        = list(string)
  description = "A list of layer ARN's (with or without aliases) to add to all functions within the Lambda application. Provides the ability to add dependencies for additional functionality such as monitoring and observability."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "Additional tags that are added to all resources in this module."
  default     = {}
}

variable "tracking_config" {
  type = string
  default = "PassThrough"
  description = "Sets the passing of sample and tracing of calls, possible values are `Passthrough`(default) or `Active`"
}