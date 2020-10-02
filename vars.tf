variable "application_name" {
  description = ""
  type        = string
}

variable "application_runtime" {
  description = ""
  type        = string
}

variable "artifact_bucket" {
  description = ""
  type        = string
}

variable "artifact_bucket_key" {
  description = ""
  type        = string
}

variable "application_environment_variables" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "application_memory" {
  description = ""
  type        = number
  default     = 128
}

variable "application_timeout" {
  description = ""
  type        = number
  default     = 3
}

variable "layer_artifact_key" {
  description = ""
  type        = string
  default     = ""
}

variable "aws_cloudwatch_log_group_retention_in_days" {
  description = ""
  type        = number
  default     = 30
}

variable "tags" {
  description = ""
  type        = map
  default     = {}
}