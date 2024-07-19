module "lambda_datastore" {
  source = "github.com/hyprnz/terraform-aws-data-storage-module?ref=v4.1.1"

  providers = {
    aws = aws
  }

  enable_datastore  = var.enable_datastore
  iam_resource_path = var.iam_resource_path

  create_rds_instance   = var.create_rds_instance
  use_rds_snapshot      = var.use_rds_snapshot
  create_s3_bucket      = var.create_s3_bucket
  create_dynamodb_table = var.create_dynamodb_table

  rds_database_name     = var.rds_database_name
  rds_identifier        = var.rds_identifier
  rds_apply_immediately = var.rds_apply_immediately

  rds_auto_minor_version_upgrade = var.rds_auto_minor_version_upgrade

  rds_engine             = var.rds_engine
  rds_engine_version     = var.rds_engine_version
  rds_instance_class     = var.rds_instance_class
  rds_subnet_group       = var.rds_subnet_group
  rds_security_group_ids = var.rds_security_group_ids

  rds_allocated_storage     = var.rds_allocated_storage
  rds_max_allocated_storage = var.rds_max_allocated_storage
  rds_iops                  = var.rds_iops

  rds_backup_retention_period = var.rds_backup_retention_period
  rds_option_group_name       = var.rds_option_group_name
  rds_multi_az                = var.rds_multi_az

  rds_monitoring_interval         = var.rds_monitoring_interval
  rds_monitoring_role_arn         = var.rds_monitoring_role_arn
  rds_enable_performance_insights = var.rds_enable_performance_insights

  rds_backup_window             = var.rds_backup_window
  rds_skip_final_snapshot       = var.rds_skip_final_snapshot
  rds_final_snapshot_identifier = var.rds_final_snapshot_identifier

  rds_enable_storage_encryption      = var.rds_enable_storage_encryption
  rds_storage_encryption_kms_key_arn = var.rds_storage_encryption_kms_key_arn

  rds_username = var.rds_username
  rds_password = var.rds_password

  rds_enable_deletion_protection = var.rds_enable_deletion_protection

  s3_bucket_name       = var.s3_bucket_name
  s3_enable_versioning = var.s3_enable_versioning

  dynamodb_table_name                    = var.dynamodb_table_name
  dynamodb_billing_mode                  = var.dynamodb_billing_mode
  dynamodb_enable_streams                = var.dynamodb_enable_streams
  dynamodb_stream_view_type              = var.dynamodb_stream_view_type
  dynamodb_enable_encryption             = var.dynamodb_enable_encryption
  dynamodb_enable_point_in_time_recovery = var.dynamodb_enable_point_in_time_recovery

  dynamodb_autoscale_read_target        = var.dynamodb_autoscale_read_target
  dynamodb_autoscale_write_target       = var.dynamodb_autoscale_write_target
  dynamodb_autoscale_min_read_capacity  = var.dynamodb_autoscale_min_read_capacity
  dynamodb_autoscale_min_write_capacity = var.dynamodb_autoscale_min_write_capacity
  dynamodb_autoscale_max_read_capacity  = var.dynamodb_autoscale_max_read_capacity
  dynamodb_autoscale_max_write_capacity = var.dynamodb_autoscale_max_write_capacity

  dynamodb_hash_key       = var.dynamodb_hash_key
  dynamodb_hash_key_type  = var.dynamodb_hash_key_type
  dynamodb_range_key      = var.dynamodb_range_key
  dynamodb_range_key_type = var.dynamodb_range_key_type

  dynamodb_ttl_enabled   = var.dynamodb_ttl_enabled
  dynamodb_ttl_attribute = var.dynamodb_ttl_attribute
  dynamodb_attributes    = var.dynamodb_attributes

  dynamodb_global_secondary_index_map = var.dynamodb_global_secondary_index_map
  dynamodb_local_secondary_index_map  = var.dynamodb_local_secondary_index_map

  dynamodb_enable_autoscaler = var.dynamodb_enable_autoscaler

  rds_tags      = var.rds_tags
  s3_tags       = var.s3_tags
  dynamodb_tags = var.dynamodb_tags
  tags          = merge({ "Lambda Application" = var.application_name }, var.datastore_tags, { "version" = var.application_version }, var.tags)
}
