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

variable "tags" {
  type        = map(any)
  description = "A map of additional tags to add to the artifactory resource."
  default     = {}
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
  default =    ""
}

variable "enable_access_logs" {
  type        = bool
  description = "Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified."
  default     = false
}