variable "create_s3_bucket" {
  type        = bool
  description = "Controls if an S3 bucket should be provisioned"
  default     = false
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the bucket. It is recommended to add a namespace/suffix to the name to avoid naming collisions"
  default     = ""
}

variable "s3_enable_versioning" {
  type        = bool
  description = "If versioning should be configured on the bucket"
  default     = true
}

variable "s3_send_bucket_notifications_to_eventbridge" {
  type        = bool
  description = "Enable bucket notifications and emit to EventBridge"
  default     = false
}

variable "s3_cors_config" {
  type = list(object({
    allowed_headers = optional(list(string), null)
    allowed_methods = optional(list(string), null)
    allowed_origins = optional(list(string), null)
    expose_headers  = optional(list(string), null)
    max_age_seconds = optional(number, null)
  }))
  description = "CORS configuration for the bucket"
  default     = []
}