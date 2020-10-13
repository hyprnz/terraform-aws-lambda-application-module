variable "application_name" {
  description = ""
  type        = string
}

variable "application_runtime" {
  description = ""
  type        = string
}

variable "lambda_functions_config" {
  type        = map(any)
  description = ""
}

variable "internal_entrypoint_config" {
  type        = map(any)
  description = ""
}

variable "artifact_bucket" {
  description = ""
  type        = string
}

variable "artifact_bucket_key" {
  description = ""
  type        = string
}

variable "application_env_vars" {
  description = ""
  type        = map(any)
  default     = {}
}

variable "application_memory" {
  description = ""
  type        = number
  default     = 128
}

variable "application_timeout" {
  description = ""
  type        = number
  default     = 3
}

variable "layer_artifact_key" {
  description = ""
  type        = string
  default     = ""
}

variable "aws_cloudwatch_log_group_retention_in_days" {
  description = ""
  type        = number
  default     = 30
}

variable "tags" {
  description = ""
  type        = map
  default     = {}
}

variable "enable_datastore_module" {
  description = "Enables the data store module that can provision data storage resources"
  default     = false
  type        = bool
}

variable "create_rds_instance" {
  description = "Controls if an RDS instance should be provisioned and integrated with the Kubernetes deployment."
  default     = false
  type        = bool
}

variable "rds_database_name" {
  description = "The database name. Can only contain alphanumeric characters and cannot be a database reserved word"
  default     = ""
}

variable "rds_identifier" {
  description = "Identifier of rds instance"
  default     = ""
}

variable "rds_password" {
  description = "RDS database password"
  default     = ""
}

variable "rds_engine" {
  description = "The Database engine for the rds instance"
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "The version of the database engine"
  default     = 11.4
}

variable "rds_instance_class" {
  description = "The instance type to use"
  default     = "db.t3.small"
}

variable "rds_monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
}

variable "rds_monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  default     = ""
}

variable "rds_enable_performance_insights" {
  description = "Controls the enabling of RDS Performance insights. Default to `true`"
  type        = bool
  default     = true
}

variable "rds_subnet_group" {
  description = "Subnet group for RDS instances"
  default     = ""
}

variable "rds_security_group_ids" {
  description = "A List of security groups to bind to the rds instance"
  type        = list(string)
  default     = []
}

variable "rds_allocated_storage" {
  description = "Amount of storage allocated to RDS instance"
  default     = 10
}

variable "rds_max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to `allocated_storage` or `0` to disable Storage Autoscaling."
  default     = 0
}

variable "rds_iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  default     = 0
}

variable "rds_enable_storage_encryption" {
  description = "Specifies whether the DB instance is encrypted"
  default     = false
}

variable "rds_storage_encryption_kms_key_arn" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used"
  default     = ""
}

variable "create_s3_bucket" {
  description = "Controls if an S3 bucket should be provisioned"
  default     = false
}

variable "s3_bucket_name" {
  description = "The name of the bucket"
  default     = ""
}

variable "s3_bucket_namespace" {
  description = "The namespace of the bucket - intention is to help avoid naming collisions"
  default     = ""
}

variable "s3_enable_versioning" {
  description = "If versioning should be configured on the bucket"
  default     = true
}

variable "dynamodb_tags" {
  description = "Additional tags (e.g map(`BusinessUnit`,`XYX`)"
  type        = map
  default     = {}
}

variable "create_dynamodb_table" {
  description = "Whether or not to enable DynamoDB resources"
  default     = false
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name. Must be supplied if creating a dynamodb table"
  type        = string
  default     = ""
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST"
  type        = string
  default     = "PROVISIONED"
}

variable "dynamodb_enable_streams" {
  description = "Enable DynamoDB streams"
  type        = bool
  default     = false
}

variable "dynamodb_stream_view_type" {
  description = "When an item in a table is modified, what information is written to the stream"
  type        = string
  # Valid values are `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE` or `NEW_AND_OLD_IMAGES`
  default = ""
}

variable "dynamodb_enable_encryption" {
  description = "Enable DynamoDB server-side encryption"
  type        = bool
  default     = true
}

variable "dynamodb_enable_point_in_time_recovery" {
  description = "Enable DynamoDB point in time recovery"
  type        = bool
  default     = true
}

variable "dynamodb_autoscale_read_target" {
  description = "The target value (in %) for DynamoDB read autoscaling"
  default     = 50
}

variable "dynamodb_autoscale_write_target" {
  description = "The target value (in %) for DynamoDB write autoscaling"
  default     = 50
}

variable "dynamodb_autoscale_min_read_capacity" {
  description = "DynamoDB autoscaling min read capacity"
  default     = 5
}

variable "dynamodb_autoscale_min_write_capacity" {
  description = "DynamoDB autoscaling min write capacity"
  default     = 5
}

variable "dynamodb_autoscale_max_read_capacity" {
  description = "DynamoDB autoscaling max read capacity"
  default     = 20
}

variable "dynamodb_autoscale_max_write_capacity" {
  description = "DynamoDB autoscaling max write capacity"
  default     = 20
}

variable "dynamodb_hash_key" {
  description = "DynamoDB table Hash Key"
  type        = string
  default     = ""
}

variable "dynamodb_hash_key_type" {
  description = "Hash Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data"
  type        = string
  default     = "S"
}

variable "dynamodb_range_key" {
  description = "DynamoDB table Range Key"
  type        = string
  default     = ""
}

variable "dynamodb_range_key_type" {
  description = "Range Key type, which must be a scalar type: `S`, `N` or `B` for (S)tring, (N)umber or (B)inary data"
  type        = string
  default     = "S"
}

variable "dynamodb_ttl_enabled" {
  description = "Whether ttl is enabled or disabled"
  default     = true
}

variable "dynamodb_ttl_attribute" {
  description = "DynamoDB table ttl attribute"
  type        = string
  default     = "Expires"
}

variable "dynamodb_attributes" {
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
  type        = list
  default     = []
}

variable "dynamodb_global_secondary_index_map" {
  description = "Additional global secondary indexes in the form of a list of mapped values"
  type        = any
  default     = []
}

variable "dynamodb_local_secondary_index_map" {
  description = "Additional local secondary indexes in the form of a list of mapped values"
  type        = list
  default     = []
}

variable "dynamodb_enable_autoscaler" {
  description = "Whether or not to enable DynamoDB autoscaling"
  type        = bool
  default     = false
}

variable "datastore_tags" {
  description = "Additional tags to add to all datastore resources"
  type        = map(string)
  default     = {}
}

variable "rds_tags" {
  description = "Additional tags for the RDS instance"
  type        = map(string)
  default     = {}
}

variable "s3_tags" {
  description = "Additional tags to be added to the s3 resources"
  default     = {}
}
