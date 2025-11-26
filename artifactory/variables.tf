variable "artifactory_bucket_name" {
  description = "The name of the S3 bucket used to store deployment artifacts for the Lambda Application"
}

variable "application_name" {
  type        = string
  description = "The name of the Lambda Application. Used to tag artifactory bucket"
}

variable "cross_account_arns" {
  type        = list(string)
  description = <<EOF
    Additional AWS account arns to provide access from.Should take the form of `arn:aws:iam::123456789012:root`.
    If no arns are supplied, no policy is created for the bucket."
  EOF
  default     = []
}

variable "force_destroy" {
  type        = bool
  description = <<EOF
    Controls if all objects in a bucket should be deleted when destroying the bucket resource.
    If set to `false`, the bucket resource cannot be destroyed until all objects are deleted.
    Defaults to `false`."
  EOF
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "A map of additional tags to add to the artifactory resource."
  default     = {}
}

variable "kms_key_arn" {
  type        = string
  description = <<EOF
  AWS KMS key ID used for the SSE-KMS encryption of the bucket.
  Will override `create_kms_key` if value is not null.
  EOF
  default     = null
}

variable "enable_versioning" {
  type        = bool
  description = "Determine if versioning is enabled for the bucket."
  default     = true
}

variable "create_kms_key" {
  type        = bool
  description = <<EOF
    Controls if a customer manager KMS key should be provisioned and used for SSE for the bucket.
    `kms_key_id` will take precedence if provided.
  EOF
  default     = false
}

variable "kms_key_key_spec" {
  type        = string
  description = <<EOF
   Specifies whether the key contains a symmetric key or an asymmetric key pair and the
   encryption algorithms or signing algorithms that the key supports.
   Valid values: `SYMMETRIC_DEFAULT`, `RSA_2048`, `RSA_3072`, `RSA_4096`, `ECC_NIST_P256`, `ECC_NIST_P384`,
   `ECC_NIST_P521`, or `ECC_SECG_P256K1`. Defaults to `SYMMETRIC_DEFAULT`
  EOF
  default     = "SYMMETRIC_DEFAULT"
}

variable "kms_key_deletion_window_in_days" {
  type        = number
  description = <<EOF
    Duration in days after which the key is deleted after destruction of the resource,
    must be between 7 and 30 days. Defaults to 30 days."
  EOF
  default     = 30
}

variable "kms_key_administrators" {
  type        = list(string)
  description = <<EOF
    A List of administrator role arns that manage the KMS key.
    Required if `create_kms_key` is `true`
  EOF
  default     = []
}

variable "kms_key_users" {
  type        = list(string)
  description = "A list of use role arns that require the ability to decrypt the KMS key."
  default     = []
}

variable "enable_eventbridge_notifications" {
  type        = bool
  description = "Enable S3 event notifications to EventBridge. When enabled, S3 object events will be automatically sent to the default EventBridge event bus."
  default     = false
}

variable "bucket_lifecycle_rules" {
  type = list(object({
    id     = string
    status = string

    filter = optional(object({
      prefix                   = optional(string)
      tags                     = optional(map(string))
      object_size_greater_than = optional(number)
      object_size_less_than    = optional(number)
    }))

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

  description = <<EOF
    List of lifecycle rules for the S3 bucket. Each rule must have an 'id' and 'status'.
    Rules can include expiration, transitions, and noncurrent version handling.
    Transitions require S3 versioning to be enabled.
  EOF

  default = []
}