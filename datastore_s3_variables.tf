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

variable "send_bucket_notifications_to_eventbridge" {
  type        = bool
  description = "Enable bucket notifications and emit to EventBridge"
  default     = false

}