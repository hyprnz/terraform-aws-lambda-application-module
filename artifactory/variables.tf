variable "artifactory_bucket_name" {
  description = "The name of the S3 bucket used to store deployment artifacts for the Lambda Application"
}

variable "application_name" {
  type        = string
  description = "The name of the Lambda Application. Used to tag artifactory bucket"
}

variable "cross_account_numbers" {
  type        = list(number)
  description = "Additional AWS accounts to provide access from. If no account ID's are supplied no policy is created for the bucket."
  default     = []
}

variable "force_destroy" {
  type        = bool
  description = "Controls if all objects in a bucket should be deleted when destroying the bucket resource. If set to `false`, the bucket resource cannot be destroyed until all objects are deleted. Defaults to `false`."
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "A map of additional tags to add to the artifactory resource."
  default     = {}
}

