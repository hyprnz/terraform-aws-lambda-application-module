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





// RDS variables ================================

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

variable "rds_backup_retention_period" {
  type        = number
  description = "The backup retention period in days"
  default     = 7
}

variable "rds_parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to create and associate with the instance"
  default     = null
}

variable "rds_parameter_group_family" {
  type        = string
  description = "Name of the DB family (engine & version) for the parameter group. eg. postgres11"
  default     = null
}

variable "rds_parameter_group_parameters" {
  type        = map(any)
  description = <<EOF
  Map of parameters that will be added to this database's parameter group.
  Parameters set here will override any AWS default parameters with the same name.
  Requires `rds_parameter_group_name` and `rds_parameter_group_family` to be set as well.
  Parameters should be provided as a key value pair within this map. eg `"param_name" : "param_value"`.
  Default is empty and the AWS default parameter group is used.
  EOF
  default     = {}
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

variable "rds_cloudwatch_logs_exports" {
  type        = set(string)
  description = "Which RDS logs should be sent to CloudWatch. The default is empty (no logs sent to CloudWatch)"
  default     = []
}

variable "rds_iam_authentication_enabled" {
  type        = bool
  description = "Controls whether you can use IAM users to log in to the RDS database. The default is `false`"
  default     = false
}
