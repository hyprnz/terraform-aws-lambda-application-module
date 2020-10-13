variable "artifactory_bucket_name" {
  description = "The name of the S3 bucket used to store deployment artifacts for the Lambda Application"
}

variable "lambda_application_name" {
  description = "The name of the Lambda Application. Used to tag artifactory bucket"
  type        = string
}

variable "cross_account_numbers" {
  description = "Addtional AWS accounts to provide access from"
  type        = list(number)
}

variable "force_destroy" {
  description = "Controls if all objects in a bucket should be deleted when destroying the bucket resource. If set to `false`, the bucket resource cannot be destroyed until all objects are deleted. Defaults to `false`."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of additional tags to add to the artifactory resource."
  type        = map(any)
  default     = {}
}

