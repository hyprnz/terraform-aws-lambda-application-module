module "lambda_datastore" {
  source = "git::git@github.com:hyprnz/terraform-aws-data-storage-module?ref=2.0.0"
  providers = {
    aws = aws
  }

  enable_datastore      = var.enable_datastore_module
  create_rds_instance   = var.create_rds_instance
  create_s3_bucket      = var.create_s3_bucket
  create_dynamodb_table = var.create_dynamodb_table

  rds_database_name  = var.rds_database_name
  rds_identifier     = var.rds_identifier
  rds_password       = var.rds_password
  rds_engine         = var.rds_engine
  rds_engine_version = var.rds_engine_version
  rds_instance_class = var.rds_instance_class

  rds_allocated_storage     = var.rds_allocated_storage
  rds_max_allocated_storage = var.rds_max_allocated_storage
  rds_iops                  = var.rds_iops

  rds_monitoring_interval         = var.rds_monitoring_interval
  rds_monitoring_role_arn         = var.rds_monitoring_role_arn
  rds_enable_performance_insights = var.rds_enable_performance_insights

  rds_subnet_group       = var.rds_subnet_group
  rds_security_group_ids = var.rds_security_group_ids

  rds_storage_encrypted              = var.rds_enable_storage_encryption
  rds_storage_encryption_kms_key_arn = var.rds_storage_encryption_kms_key_arn

  s3_bucket_name       = var.s3_bucket_name
  s3_bucket_namespace  = var.s3_bucket_namespace
  s3_enable_versioning = var.s3_enable_versioning

  dynamodb_table_name                    = var.dynamodb_table_name
  dynamodb_billing_mode                  = var.dynamodb_billing_mode
  dynamodb_enable_streams                = var.dynamodb_enable_streams
  dynamodb_stream_view_type              = var.dynamodb_stream_view_type
  dynamodb_enable_encryption             = var.dynamodb_enable_encryption
  dynamodb_enable_point_in_time_recovery = var.dynamodb_enable_point_in_time_recovery

  dynamodb_hash_key       = var.dynamodb_hash_key
  dynamodb_hash_key_type  = var.dynamodb_hash_key_type
  dynamodb_range_key      = var.dynamodb_range_key
  dynamodb_range_key_type = var.dynamodb_range_key_type

  dynamodb_attributes = var.dynamodb_attributes

  dynamodb_global_secondary_index_map = var.dynamodb_global_secondary_index_map
  dynamodb_local_secondary_index_map  = var.dynamodb_local_secondary_index_map

  dynamodb_enable_autoscaler            = var.dynamodb_enable_autoscaler
  dynamodb_autoscale_read_target        = var.dynamodb_autoscale_read_target
  dynamodb_autoscale_write_target       = var.dynamodb_autoscale_write_target
  dynamodb_autoscale_min_read_capacity  = var.dynamodb_autoscale_min_read_capacity
  dynamodb_autoscale_min_write_capacity = var.dynamodb_autoscale_min_write_capacity
  dynamodb_autoscale_max_read_capacity  = var.dynamodb_autoscale_max_read_capacity
  dynamodb_autoscale_max_write_capacity = var.dynamodb_autoscale_max_write_capacity

  dynamodb_ttl_enabled   = var.dynamodb_ttl_enabled
  dynamodb_ttl_attribute = var.dynamodb_ttl_attribute

  rds_tags      = var.rds_tags
  s3_tags       = var.s3_tags
  dynamodb_tags = var.dynamodb_tags
  tags          = merge(map("Lambda Application", var.application_name), var.datastore_tags)
}
