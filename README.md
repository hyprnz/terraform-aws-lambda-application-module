# Terraform AWS Lambda Application Module

This module supports the creation of AWS resources for a Lambda Application Architecture style service. This is a work in progress and is currently in a POC implementation.

It requires a Lambda Application Architecture and build/pipeline conventions in order to be of value. An example implementation of this architecture will be provided in the future.

## The Lambda Application

The Lambda Application is a design that consists of `n` functions that have the concept of *internal* or *external* entrypoints. *External* entrypoints are events external to the application which triggers the start of the Lambda Application process. This could be an S3 and/or API gateway event. The current implementation is using an S3 event which is managed outside of the application, hence no apparent configuration variable. It is still uncertain how this will look configuration wise and if *external* entrypoints encapsulates the language of this architecture, or a more resource orientated naming convention (i.e. s3_event_entrypoints) concept is best. There is some more work trying to understand use cases where an external entrypoint is a concern of the Lambda Application, and how this would impact the current module design.

*Internal* entrypoints are how functions in the Lambda Application can pass events to each other. All *internal* entrypoints will use EventBridge as the means to relay events and require some configuration. The configuration for this is still taking shape. It is intended that an sole Event Bus be created, but no support for this exists in the current provider (support is now available see [issue #16](https://github.com/hyprnz/terraform-aws-lambda-application-module/issues/16)).

## Context
Given the early stage of this module, it is advised this not be used in production until further examples can be provided. This is an opinionated module and as such requires a context for it to be an effective way to provision Lambda resources. It has only tested with the `Python 3.8` & `Nodejs 18` runtimes and there are some questions on how other language runtimes will impact the design of this module. Please do reach out of you are curious or interested in contributing to the work being done here.

## Artifactory Module
A stand alone artifactory module has been provided as a stand alone module to cater for the creation of an artifactory bucket in a different AWS account. The [README](artifactory/README.md) contains more info.

## Alb Module
A stand alone alb module has been provided as a stand alone module to cater for the creation of an Application load balancer that supports Lambda target type. The [README](alb/README.md) contains more info.

---
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | >= 5.26.0, <6.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.26.0, <6.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| lambda_datastore | git::git@github.com:hyprnz/terraform-aws-data-storage-module | 4.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_name | Repo name of the lambda application. | `string` | n/a | yes |
| application_runtime | Lambda runtime for the application. | `string` | n/a | yes |
| application_version | Version of the function(s) deployed for the application. | `string` | n/a | yes |
| artifact_bucket | Bucket that stores function artifacts. Includes layer dependencies. | `string` | n/a | yes |
| artifact_bucket_key | File name key of the artifact to load. | `string` | n/a | yes |
| internal_entrypoint_config | Map of configurations of internal entrypoints. | `map(any)` | n/a | yes |
| lambda_functions_config | Map of functions and associated configurations. | `map(any)` | n/a | yes |
| additional_layers | A list of layer ARN's (with or without aliases) to add to all functions within the Lambda application. Provides the ability to add dependencies for additional functionality such as monitoring and observability. | `list(string)` | `[]` | no |
| alb_lambda_listener_arn | Listener ARN of ALB | `string` | `""` | no |
| alias_description | Name of the alias being created | `string` | `""` | no |
| alias_name | Name of the alias being created | `string` | `""` | no |
| application_env_vars | Map of environment variables required by any function in the application. | `map(any)` | `{}` | no |
| application_memory | Memory allocated to all functions in the application. Defaults to `128`. | `number` | `128` | no |
| application_timeout | Timeout in seconds for all functions in the application. Defaults to `3`. | `number` | `3` | no |
| aws_cloudwatch_log_group_retention_in_days | The retention period in days of all log group created for each function. Defaults to `30`. | `number` | `30` | no |
| create_dynamodb_table | Whether or not to enable DynamoDB resources | `bool` | `false` | no |
| create_rds_instance | Controls if an RDS instance should be provisioned. Will take precedence if this and `use_rds_snapshot` are both true. | `bool` | `false` | no |
| create_s3_bucket | Controls if an S3 bucket should be provisioned | `bool` | `false` | no |
| custom_policy_description | Allows to override the custom Lambda policy's description | `string` | `""` | no |
| custom_policy_document | A valid policy json string that defines additional actions required by the execution role of the Lambda function | `string` | `""` | no |
| datastore_tags | Tags for all datastore resources | `map(any)` | `{}` | no |
| domain_name | The custom domain name for api gateway that points to lambda application | `string` | `""` | no |
| dynamodb_attributes | Additional DynamoDB attributes in the form of a list of mapped values | `list(any)` | `[]` | no |
| dynamodb_autoscale_max_read_capacity | DynamoDB autoscaling max read capacity | `number` | `20` | no |
| dynamodb_autoscale_max_write_capacity | DynamoDB autoscaling max write capacity | `number` | `20` | no |
| dynamodb_autoscale_min_read_capacity | DynamoDB autoscaling min read capacity | `number` | `5` | no |
| dynamodb_autoscale_min_write_capacity | DynamoDB autoscaling min write capacity | `number` | `5` | no |
| dynamodb_autoscale_read_target | The target value (in %) for DynamoDB read autoscaling | `number` | `50` | no |
| dynamodb_autoscale_write_target | The target value (in %) for DynamoDB write autoscaling | `number` | `50` | no |
| dynamodb_billing_mode | DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST | `string` | `"PROVISIONED"` | no |
| dynamodb_enable_autoscaler | Whether or not to enable DynamoDB autoscaling | `bool` | `false` | no |
| dynamodb_enable_encryption | Enable DynamoDB server-side encryption | `bool` | `true` | no |
| dynamodb_enable_point_in_time_recovery | Enable DynamoDB point in time recovery | `bool` | `true` | no |
| dynamodb_enable_streams | Enable DynamoDB streams | `bool` | `false` | no |
| dynamodb_global_secondary_index_map | Additional global secondary indexes in the form of a list of mapped values | `any` | `[]` | no |
| dynamodb_hash_key | DynamoDB table Hash Key | `string` | `""` | no |
| dynamodb_hash_key_type | Hash Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| dynamodb_local_secondary_index_map | Additional local secondary indexes in the form of a list of mapped values | `list(any)` | `[]` | no |
| dynamodb_range_key | DynamoDB table Range Key | `string` | `""` | no |
| dynamodb_range_key_type | Range Key type, which must be a scalar type: `S`, `N` or `B` for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| dynamodb_stream_view_type | When an item in a table is modified, what information is written to the stream | `string` | `""` | no |
| dynamodb_table_name | DynamoDB table name. Must be supplied if creating a dynamodb table | `string` | `""` | no |
| dynamodb_tags | Additional tags e.g map(`BusinessUnit`,`XYX`) | `map(any)` | `{}` | no |
| dynamodb_ttl_attribute | DynamoDB table ttl attribute | `string` | `"Expires"` | no |
| dynamodb_ttl_enabled | Whether ttl is enabled or disabled | `bool` | `true` | no |
| enable_api_gateway | Allow to create api-gateway | `bool` | `false` | no |
| enable_datastore | Enables the data store module that will provision data storage resources | `bool` | `true` | no |
| enable_load_balancer | Allow to create load balancer | `bool` | `false` | no |
| lambda_alb_config | Contains entry point lambda function key | `map(string)` | `{}` | no |
| layer_artifact_key | File name key of the layer artifact to load. | `string` | `""` | no |
| msk_arn | the MSK source arn for all lambda requires MSK | `string` | `""` | no |
| msk_event_source_config | Map of configurations of MSK event source for each lambda | `map(any)` | `{}` | no |
| parameter_store_path | SSM parameter path | `string` | `""` | no |
| rds_allocated_storage | Amount of storage allocated to RDS instance | `number` | `100` | no |
| rds_apply_immediately | Specifies whether any database modifications are applied immediately, or during the next maintenance window. Defaults to `false`. | `bool` | `false` | no |
| rds_auto_minor_version_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Defaults to `true`. | `bool` | `true` | no |
| rds_backup_retention_period | The backup retention period in days | `number` | `7` | no |
| rds_backup_window | The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window | `string` | `"16:19-16:49"` | no |
| rds_cloudwatch_logs_exports | Which RDS logs should be sent to CloudWatch. The default is empty (no logs sent to CloudWatch) | `set(string)` | `[]` | no |
| rds_database_name | The name of the database. Can only contain alphanumeric characters | `string` | `""` | no |
| rds_enable_deletion_protection | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to `true`. The default is `false`. | `bool` | `false` | no |
| rds_enable_performance_insights | Controls the enabling of RDS Performance insights. Default to `true` | `bool` | `true` | no |
| rds_enable_storage_encryption | Specifies whether the DB instance is encrypted | `bool` | `false` | no |
| rds_engine | The Database engine for the rds instance | `string` | `"postgres"` | no |
| rds_engine_version | The version of the database engine. | `string` | `"11"` | no |
| rds_final_snapshot_identifier | The name of your final DB snapshot when this DB instance is deleted. Must be provided if `rds_skip_final_snapshot` is set to false. The value must begin with a letter, only contain alphanumeric characters and hyphens, and not end with a hyphen or contain two consecutive hyphens. | `string` | `null` | no |
| rds_iam_authentication_enabled | Controls whether you can use IAM users to log in to the RDS database. The default is `false` | `bool` | `false` | no |
| rds_identifier | Identifier of datastore instance | `string` | `""` | no |
| rds_instance_class | The instance type to use | `string` | `"db.t3.small"` | no |
| rds_iops | The amount of provisioned IOPS. Setting this implies a storage_type of 'io1' | `number` | `0` | no |
| rds_max_allocated_storage | The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to `allocated_storage` or `0` to disable Storage Autoscaling. | `number` | `200` | no |
| rds_monitoring_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `0` | no |
| rds_monitoring_role_arn | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring_interval is non-zero. | `string` | `""` | no |
| rds_multi_az | Specifies if the RDS instance is multi-AZ. | `bool` | `false` | no |
| rds_option_group_name | Name of the DB option group to associate | `string` | `null` | no |
| rds_parameter_group_family | Name of the DB family (engine & version) for the parameter group. eg. postgres11 | `string` | `null` | no |
| rds_parameter_group_name | Name of the DB parameter group to create and associate with the instance | `string` | `null` | no |
| rds_parameter_group_parameters | Map of parameters that will be added to this database's parameter group.<br>  Parameters set here will override any AWS default parameters with the same name.<br>  Requires `rds_parameter_group_name` and `rds_parameter_group_family` to be set as well.<br>  Parameters should be provided as a key value pair within this map. eg `"param_name" : "param_value"`.<br>  Default is empty and the AWS default parameter group is used. | `map(any)` | `{}` | no |
| rds_password | RDS database password for the user | `string` | `""` | no |
| rds_security_group_ids | A List of security groups to bind to the rds instance | `list(string)` | `[]` | no |
| rds_skip_final_snapshot | Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier | `bool` | `true` | no |
| rds_storage_encryption_kms_key_arn | The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage_encrypted is set to true and kms_key_id is not specified the default KMS key created in your account will be used | `string` | `""` | no |
| rds_subnet_group | Subnet group for RDS instances | `string` | `""` | no |
| rds_tags | Additional tags for rds datastore resources | `map(any)` | `{}` | no |
| rds_username | RDS database user name | `string` | `""` | no |
| s3_bucket_name | The name of the bucket. It is recommended to add a namespace/suffix to the name to avoid naming collisions | `string` | `""` | no |
| s3_enable_versioning | If versioning should be configured on the bucket | `bool` | `true` | no |
| s3_tags | Additional tags to be added to the s3 resources | `map(any)` | `{}` | no |
| service_target_group_name | The service target group attached to application load balancer listener | `string` | `""` | no |
| service_target_group_path | The target path attached to the service target group | `string` | `""` | no |
| ssm_kms_key_arn | Either he customer managed KMS or AWS manages key arn used for encrypting `SecureSting` parameters | `string` | `""` | no |
| tags | Additional tags that are added to all resources in this module. | `map(any)` | `{}` | no |
| tracking_config | Sets the passing of sample and tracing of calls, possible values are `Passthrough`(default) or `Active` | `string` | `"PassThrough"` | no |
| use_rds_snapshot | Controls if an RDS snapshot should be used when creating the rds instance. Will use the latest snapshot of the `rds_identifier` variable. | `bool` | `false` | no |
| vpc_security_group_ids | List of security group IDs associated with the Lambda function | `list(string)` | `[]` | no |
| vpc_subnet_ids | List of subnet IDs associated with the Lambda function | `list(string)` | `[]` | no |
| zone_id | Route 53 hosted zone id | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain_id | n/a |

<br/>

---
## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```
Copyright 2020 Hypr NZ

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Copyright &copy; 2020 [Hypr NZ](https://www.hypr.nz/)
<!-- END_TF_DOCS -->