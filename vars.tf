variable "application_name" {
  type        = string
  description = "Repo name of the lambda application."
}

variable "application_runtime" {
  type        = string
  description = "Lambda runtime for the application."
}

variable "lambda_functions_config" {
  type        = map(any)
  description = "Map of functions and associated configurations."
}

variable "internal_entrypoint_config" {
  type        = map(any)
  description = "Map of configuations of internal entrypoints."
}

variable "artifact_bucket" {
  type        = string
  description = "Bucket that stores function artifacts. Includes layer dependencies."
}

variable "artifact_bucket_key" {
  type        = string
  description = "File name key of the artifact to load."
}

variable "application_env_vars" {
  type        = map(any)
  description = "Map of environment variables required by any function in the application."
  default     = {}
}

variable "application_memory" {
  type        = number
  description = "Memory allocated to all functions in the application. Defaults to `128`."
  default     = 128
}

variable "application_timeout" {
  type        = number
  description = "Timeout in seconds for all functions in the application. Defaults to `3`."
  default     = 3
}

variable "layer_artifact_key" {
  type        = string
  description = "File name key of the layer artifact to load."
  default     = ""
}

variable "aws_cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "The retention period in days of all log group created for each function. Defaults to `30`."
  default     = 30
}

variable "tags" {
  type        = map
  description = "Additional tags that are added to all resources in this module."
  default     = {}
}

variable "enable_datastore_module" {
  type        = bool
  description = "Enables the data store module that can provision data storage resources"
  default     = false
}

variable "create_rds_instance" {
  type        = bool
  description = "Controls if an RDS instance should be provisioned and integrated with the Kubernetes deployment."
  default     = false
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
  type        = bool
  description = "Controls the enabling of RDS Performance insights. Default to `true`"
  default     = true
}

variable "rds_subnet_group" {
  description = "Subnet group for RDS instances"
  default     = ""
}

variable "rds_security_group_ids" {
  type        = list(string)
  description = "A List of security groups to bind to the rds instance"
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
  type        = map
  description = "Additional tags (e.g map(`BusinessUnit`,`XYX`)"
  default     = {}
}

variable "create_dynamodb_table" {
  description = "Whether or not to enable DynamoDB resources"
  default     = false
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
  # Valid values are `KEYS_ONLY`, `NEW_IMAGE`, `OLD_IMAGE` or `NEW_AND_OLD_IMAGES`
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
  description = "Whether ttl is enabled or disabled"
  default     = true
}

variable "dynamodb_ttl_attribute" {
  type        = string
  description = "DynamoDB table ttl attribute"
  default     = "Expires"
}

variable "dynamodb_attributes" {
  type        = list
  description = "Additional DynamoDB attributes in the form of a list of mapped values"
  default     = []
}

variable "dynamodb_global_secondary_index_map" {
  type        = any
  description = "Additional global secondary indexes in the form of a list of mapped values"
  default     = []
}

variable "dynamodb_local_secondary_index_map" {
  type        = list
  description = "Additional local secondary indexes in the form of a list of mapped values"
  default     = []
}

variable "dynamodb_enable_autoscaler" {
  type        = bool
  description = "Whether or not to enable DynamoDB autoscaling"
  default     = false
}

variable "datastore_tags" {
  type        = map(string)
  description = "Additional tags to add to all datastore resources"
  default     = {}
}

variable "rds_tags" {
  type        = map(string)
  description = "Additional tags for the RDS instance"
  default     = {}
}

variable "s3_tags" {
  description = "Additional tags to be added to the s3 resources"
  default     = {}
}


