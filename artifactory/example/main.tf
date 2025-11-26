module "example" {
  source = "../"

  providers = {
    aws = aws
  }

  artifactory_bucket_name = "tfm-exm-stage-artifactory"
  application_name        = "lambda-app"
  cross_account_arns      = var.cross_account_arns
  force_destroy           = true

  create_kms_key                  = true
  kms_key_administrators          = var.kms_key_administrators
  kms_key_users                   = var.kms_key_users
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days

  # Enable EventBridge notifications
  enable_eventbridge_notifications = var.enable_eventbridge_notifications

  # Configure lifecycle rules for artifact retention and cost optimization
  bucket_lifecycle_rules = var.bucket_lifecycle_rules
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  default = "us-west-2"
}

variable "cross_account_arns" {
  type        = list(string)
  description = <<EOF
    Additional AWS accounts to provide access from. If no account ID's are supplied
    no policy is created for the bucket."
  EOF
  default     = []
}

variable "kms_key_administrators" {
  type        = list(string)
  description = <<EOF
    A List of administrator role arns that manage the SSE key.
    Required if `create_kms_key` is `true`
  EOF
  default     = []
}

variable "kms_key_users" {
  type        = list(string)
  description = "A list of use role arns that require the ability to decrypt the SSE key."
  default     = []
}

variable "kms_key_deletion_window_in_days" {
  type        = number
  description = <<EOF
    Duration in days after which the key is deleted after destruction of the resource,
    must be between 7 and 30 days. Defaults to 30 days."
  EOF
  default     = 7
}

variable "enable_eventbridge_notifications" {
  type        = bool
  description = "Enable EventBridge notifications for the bucket"
  default     = false
}

variable "bucket_lifecycle_rules" {
  type = list(object({
    id     = string
    status = string

    filter = optional(object({
      prefix = optional(string, null)
      tags   = optional(map(string), null)
    }), null)

    expiration = optional(object({
      days                         = optional(number)
      date                         = optional(string)
      expired_object_delete_marker = optional(bool)
    }))

    noncurrent_version_expiration = optional(object({
      days = number
    }))

    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))

    noncurrent_version_transitions = optional(list(object({
      days          = number
      storage_class = string
    })))

    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
  }))

  description = "Lifecycle rules for the S3 bucket"
  default     = []
}

output "bucket_name" {
  value = module.example.bucket_name
}

output "bucket_arn" {
  value = module.example.bucket_arn
}

output "eventbridge_notifications_enabled" {
  value = module.example.eventbridge_notifications_enabled
}

output "lifecycle_configuration_enabled" {
  value = module.example.lifecycle_configuration_enabled
}
