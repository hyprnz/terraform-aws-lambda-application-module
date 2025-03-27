variable "artifactory_bucket_name" {
  description = "The name of the S3 bucket used to store deployment artifacts for the Lambda Application"
}

variable "application_name" {
  type        = string
  description = "The name of the Lambda Application. Used to tag artifactory bucket"
}

variable "cross_account_numbers" {
  type        = list(string)
  description = <<EOF
    Additional AWS accounts to provide access from. If no account ID's are supplied
    no policy is created for the bucket."
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
    A List of administrator role arns that manage the SSE key.
    Required if `create_kms_key` is `true`
  EOF
  default     = []
}