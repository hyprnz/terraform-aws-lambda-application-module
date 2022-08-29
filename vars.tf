variable "application_name" {
  type        = string
  description = "Repo name of the lambda application."
}

variable "application_runtime" {
  type        = string
  description = "Lambda runtime for the application."
}

variable "application_version" {
  type        = string
  description = "Version of the function(s) deployed for the application."
}

variable "lambda_functions_config" {
  type        = map(any)
  description = "Map of functions and associated configurations."
}

variable "lambda_alb_config" {
  type        = map(string)
  description = "Contains entry point lambda function key"
  default     = {}
}

variable "internal_entrypoint_config" {
  type        = map(any)
  description = "Map of configurations of internal entrypoints."
}
variable "alb_lambda_listener_arn" {
  type        = string
  description = "Listener ARN of ALB"
  default     = ""
}

variable "msk_arn" {
  type        = string
  description = "the MSK source arn for all lambda requires MSK"
  default     = ""
}

variable "msk_event_source_config" {
  type        = map(any)
  description = "Map of configurations of MSK event source for each lambda"
  default     = {}
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

variable "vpc_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs associated with the Lambda function"
  default     = []
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs associated with the Lambda function"
  default     = []
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

variable "enable_api_gateway" {
  type        = bool
  description = "Allow to create api-gateway"
  default     = false
}

variable "zone_id" {
  type        = string
  description = "Route 53 hosted zone id"
}

variable "domain_name" {
  type        = string
  description = "The custom domain name for api gateway that points to lambda application"
}

variable "parameter_store_path" {
  type        = string
  description = "SSM parameter path"
}

variable "ssm_kms_key_arn" {
  type        = string
  description = "KMS key arn"
}

variable "alias_name" {
  type        = string
  description = "Name of the alias being created"
}

variable "alias_description" {
  type        = string
  description = "Name of the alias being created"
  default     = "Alias that points to the current lambda application version"
}

variable "custom_policy_document" {
  type        = string
  description = "A valid policy json string that defines additional actions required by the execution role of the Lambda function"
  default     = ""
}

variable "custom_policy_description" {
  type        = string
  description = "Allows to override the custom Lambda policy's description"
  default     = "The custom policy for the Lambda application module execution role"
}

variable "additional_layers" {
  type        = list(string)
  description = "A list of layer ARN's (with or without aliases) to add to all functions within the Lambda application. Provides the ability to add dependencies for additional functionality such as monitoring and observability."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "Additional tags that are added to all resources in this module."
  default     = {}
}

variable "enable_load_balancer" {
  type        = bool
  description = "Allow to create load balancer"
  default     = false
}

variable "service_target_group_name" {
  type        = string
  description = "The service target group attached to application load balancer listener"
}

variable "service_target_group_path" {
  type        = string
  description = "The target path attached to the service target group"
}

# datastore variables ==========================

variable "enable_datastore_module" {
  type        = bool
  description = "Enables the data store module that will provision data storage resources"
  default     = true
}

variable "create_rds_instance" {
  type        = bool
  description = "Controls if an RDS instance should be provisioned. Will take precedence if this and `use_rds_snapshot` are both true."
  default     = false
}

variable "use_rds_snapshot" {
  type        = bool
  description = "Controls if an RDS snapshot should be used when creating the rds instance. Will use the latest snapshot of the `rds_identifier` variable."
  default     = false
}

variable "create_s3_bucket" {
  type        = bool
  description = "Controls if an S3 bucket should be provisioned"
  default     = false
}

variable "create_dynamodb_table" {
  type        = bool
  description = "Whether or not to enable DynamoDB resources"
  default     = false
}

variable "datastore_tags" {
  type        = map(string)
  description = "Additional tags to add to all datastore resources"
  default     = {}
}

# RDS variables ================================

variable "rds_tags" {
  type        = map
  description = "Additional tags for rds datastore resources"
  default     = {}
}

variable "rds_database_name" {
  type        = string
  description = "The name of the database. Can only contain alphanumeric characters"
  default     = ""
}

variable "rds_identifier" {
  type        = string
  description = "Identifier of datastore instance"
  default     = ""
}

variable "rds_apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window. Defaults to `false`."
  default     = false
}

variable "rds_auto_minor_version_upgrade" {
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Defaults to `true`."
  default     = true
}

variable "rds_engine" {
  type        = string
  description = "The Database engine for the rds instance"
  default     = "postgres"
}

variable "rds_engine_version" {
  type        = string
  description = "The version of the database engine."
  default     = "11"
}

variable "rds_instance_class" {
  type        = string
  description = "The instance type to use"
  default     = "db.t3.small"
}

variable "rds_subnet_group" {
  type        = string
  description = "Subnet group for RDS instances"
  default     = ""
}

variable "rds_security_group_ids" {
  type        = list(string)
  description = "A List of security groups to bind to the rds instance"
  default     = []
}

variable "rds_allocated_storage" {
  type        = number
  description = "Amount of storage allocated to RDS instance"
  default     = 100
}

variable "rds_max_allocated_storage" {
  type        = number
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to `allocated_storage` or `0` to disable Storage Autoscaling."
  default     = 200
}

variable "rds_iops" {
  type        = number
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  default     = 0
}

variable "backup_retention_period" {
  type        = number
  description = "The backup retention period in days"
  default     = 7
}

variable "rds_option_group_name" {
  type        = string
  description = "Name of the DB option group to associate"
  default     = null
}

variable "rds_multi_az" {
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ."
  default     = false
}

variable "rds_monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
}

variable "rds_monitoring_role_arn" {
  type        = string
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero."
  default     = ""
}

variable "rds_enable_performance_insights" {
  type        = bool
  description = "Controls the enabling of RDS Performance insights. Default to `true`"
  default     = true
}

variable "rds_backup_window" {
  type        = string
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  default     = "16:19-16:49"
}

variable "rds_skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  default     = true
}

variable "rds_final_snapshot_identifier" {
  type        = string
  description = "The name of your final DB snapshot when this DB instance is deleted. Must be provided if `rds_skip_final_snapshot` is set to false. The value must begin with a letter, only contain alphanumeric characters and hyphens, and not end with a hyphen or contain two consecutive hyphens."
  default     = null
}

variable "rds_enable_storage_encryption" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted"
  default     = false
}

variable "rds_storage_encryption_kms_key_arn" {
  type        = string
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used"
  default     = ""
}

variable "rds_username" {
  type        = string
  description = "RDS database user name"
  default     = ""
}

variable "rds_password" {
  type        = string
  description = "RDS database password for the user"
  default     = ""
}

variable "rds_enable_deletion_protection" {
  type        = bool
  description = " If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`."
  default     = false
}

// s3 variables =================================

variable "s3_tags" {
  type        = map
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

# Dynamodb variables ===========================

variable "dynamodb_tags" {
  type        = map
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
