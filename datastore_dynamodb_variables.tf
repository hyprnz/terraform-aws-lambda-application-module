variable "create_dynamodb_table" {
  type        = bool
  description = "Whether or not to enable DynamoDB resources"
  default     = false
}

variable "dynamodb_tags" {
  type        = map(any)
  description = "Additional tags (e.g map(`BusinessUnit`,`XYX`)"
  default     = {}
}

variable "dynamodb_table_name" {
  type        = string
  description = "DynamoDB table name. Must be supplied if creating a dynamodb table"
  default     = ""
}

variable "dynamodb_billing_mode" {
  type        = string
  description = "DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST"
  default     = "PROVISIONED"
}

variable "dynamodb_enable_streams" {
  type        = bool
  description = "Enable DynamoDB streams"
  default     = false
}

variable "dynamodb_stream_view_type" {
  type        = string
  description = "When an item in a table is modified, what information is written to the stream"
  #Valid values are `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE` or `NEW_AND_OLD_IMAGES`
  default = ""
}

variable "dynamodb_enable_encryption" {
  type        = bool
  description = "Enable DynamoDB server-side encryption"
  default     = true
}

variable "dynamodb_enable_point_in_time_recovery" {
  type        = bool
  description = "Enable DynamoDB point in time recovery"
  default     = true
}

variable "dynamodb_autoscale_read_target" {
  type        = number
  description = "The target value (in %) for DynamoDB read autoscaling"
  default     = 50
}

variable "dynamodb_autoscale_write_target" {
  type        = number
  description = "The target value (in %) for DynamoDB write autoscaling"
  default     = 50
}

variable "dynamodb_autoscale_min_read_capacity" {
  type        = number
  description = "DynamoDB autoscaling min read capacity"
  default     = 5
}

variable "dynamodb_autoscale_min_write_capacity" {
  type        = number
  description = "DynamoDB autoscaling min write capacity"
  default     = 5
}

variable "dynamodb_autoscale_max_read_capacity" {
  type        = number
  description = "DynamoDB autoscaling max read capacity"
  default     = 20
}

variable "dynamodb_autoscale_max_write_capacity" {
  type        = number
  description = "DynamoDB autoscaling max write capacity"
  default     = 20
}

variable "dynamodb_hash_key" {
  type        = string
  description = "DynamoDB table Hash Key"
  default     = ""
}

variable "dynamodb_hash_key_type" {
  type        = string
  description = "Hash Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data"
  default     = "S"
}

variable "dynamodb_range_key" {
  type        = string
  description = "DynamoDB table Range Key"
  default     = ""
}

variable "dynamodb_range_key_type" {
  type        = string
  description = "Range Key type, which must be a scalar type: `S`, `N` or `B` for (S)tring, (N)umber or (B)inary data"
  default     = "S"
}

variable "dynamodb_ttl_enabled" {
  type        = bool
  description = "Whether ttl is enabled or disabled"
  default     = true
}

variable "dynamodb_ttl_attribute" {
  type        = string
  description = "DynamoDB table ttl attribute"
  default     = "Expires"
}

variable "dynamodb_attributes" {
  type        = list(any)
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
  default     = []
}

variable "dynamodb_global_secondary_index_map" {
  type        = any
  description = "Additional global secondary indexes in the form of a list of mapped values"
  default     = []
}

variable "dynamodb_local_secondary_index_map" {
  type        = list(any)
  description = "Additional local secondary indexes in the form of a list of mapped values"
  default     = []
}

variable "dynamodb_enable_autoscaler" {
  type        = bool
  description = "Whether or not to enable DynamoDB autoscaling"
  default     = false
}
