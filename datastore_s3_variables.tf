// s3 variables =================================

variable "s3_tags" {
  type        = map(any)
  description = "Additional tags to be added to the s3 resources"
  default     = {}
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
