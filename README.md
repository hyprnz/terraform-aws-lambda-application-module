# Terraform AWS Lambda Application Module

This module supports the creation of AWS resources for a Lambda Application Architecture style service. This is a work in progress and is currently in a POC implementation.

It requires a Lambda Application Arichecture and build/pipeline conventions in order to be of use. An example implementation of this architecture will be provided in the future.

## The Lambda Application

The Lambda Application is a design that consists of `n` functions that have the concept of *internal* or *external* entrypoints. *External* entrypoints are events external to the application which triggers the start of the Lambda Application process. This could be an S3 and/or API gateway event. The current implementation is using an S3 event which is managed outside of the application, hence no apparent configuration variable. API Gateway *external* entrypoints are planned to be added in the near future. It is still uncertain how this will look configuration wise and if *external* entrypoints encapsulates the architecture, or a more resource name orientated (i.e. s3_event_entrypoints) concept is better. There is some more work trying to understand use cases where an external entrypoint is a concern of the Lambda Application, and how this would impact the current module design.

*Internal* entrypoints are how functions in the Lambda Application can pass events to each other. All *internal* entrypoints will use EventBridge as the means to relay events and required some configuration. The configuration for this is still taking shape. It is intended that an sole Event Bus be created, but no support for this exists in the current provider. Although it has been stated this should be available relatively soon.

## Context
Given the stage of this module it is advised this not be used until further resources can be provided. This is an opinionated module and as such requires a context for it to be an effective way to provision Lambda resources. It has only been tested with the `Python 3.8` runtime and there are some questions on how other language runtimes will impact the design of this module. Please do reach out of you are curious or interested in the work being don here.

## Artifactory Module
A stand alone artifactory module has been provided as a stand alone module to cater for the creation of an artifactory bucket in a different AWS account. The [README](artifactory/README.md) contains more info.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | > 0.12.6, < 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_datastore"></a> [lambda\_datastore](#module\_lambda\_datastore) | git::git@github.com:hyprnz/terraform-aws-data-storage-module?ref=2.0.2 |  |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_apigatewayv2_api.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_api_mapping.api_gateway_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping) | resource |
| [aws_apigatewayv2_domain_name.api_gateway_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_domain_name) | resource |
| [aws_cloudwatch_event_rule.internal_entrypoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_internal_entrypoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.lambda_application_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.custom_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.event_bridge_internal_entrypoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.lambda_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_application_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.custom_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datastore_dynamodb_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.datastore_s3_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.event_bridge_internal_entrypoint_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_application_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.msk_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.s3_default_read_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_alias.lambda_application_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_event_source_mapping.msk_event_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.lambda_application](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.runtime_dependencies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.allow_apigateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.internal_entrypoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_route53_record.api_gateway_live](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_iam_policy_document.event_bridge_internal_entrypoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_application_assume_role_statement](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_vpc_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_parameters_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_layers"></a> [additional\_layers](#input\_additional\_layers) | A List of additional layers to be added to the function | `list(string)` | `[]` | no |
| <a name="input_alias_description"></a> [alias\_description](#input\_alias\_description) | Name of the alias being created | `string` | `"Alias that points to the current lambda application version"` | no |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | Name of the alias being created | `string` | n/a | yes |
| <a name="input_application_env_vars"></a> [application\_env\_vars](#input\_application\_env\_vars) | Map of environment variables required by any function in the application. | `map(any)` | `{}` | no |
| <a name="input_application_memory"></a> [application\_memory](#input\_application\_memory) | Memory allocated to all functions in the application. Defaults to `128`. | `number` | `128` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Repo name of the lambda application. | `string` | n/a | yes |
| <a name="input_application_runtime"></a> [application\_runtime](#input\_application\_runtime) | Lambda runtime for the application. | `string` | n/a | yes |
| <a name="input_application_timeout"></a> [application\_timeout](#input\_application\_timeout) | Timeout in seconds for all functions in the application. Defaults to `3`. | `number` | `3` | no |
| <a name="input_application_version"></a> [application\_version](#input\_application\_version) | Version of the function(s) deployed for the application. | `string` | n/a | yes |
| <a name="input_artifact_bucket"></a> [artifact\_bucket](#input\_artifact\_bucket) | Bucket that stores function artifacts. Includes layer dependencies. | `string` | n/a | yes |
| <a name="input_artifact_bucket_key"></a> [artifact\_bucket\_key](#input\_artifact\_bucket\_key) | File name key of the artifact to load. | `string` | n/a | yes |
| <a name="input_aws_cloudwatch_log_group_retention_in_days"></a> [aws\_cloudwatch\_log\_group\_retention\_in\_days](#input\_aws\_cloudwatch\_log\_group\_retention\_in\_days) | The retention period in days of all log group created for each function. Defaults to `30`. | `number` | `30` | no |
| <a name="input_create_dynamodb_table"></a> [create\_dynamodb\_table](#input\_create\_dynamodb\_table) | Whether or not to enable DynamoDB resources | `bool` | `false` | no |
| <a name="input_create_rds_instance"></a> [create\_rds\_instance](#input\_create\_rds\_instance) | Controls if an RDS instance should be provisioned and integrated with the Kubernetes deployment. | `bool` | `false` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Controls if an S3 bucket should be provisioned | `bool` | `false` | no |
| <a name="input_custom_policy_description"></a> [custom\_policy\_description](#input\_custom\_policy\_description) | Allows to override the custom Lambda policy's description | `string` | `"The custom policy for the Lambda application module execution role"` | no |
| <a name="input_custom_policy_document"></a> [custom\_policy\_document](#input\_custom\_policy\_document) | A valid policy json string that defines additional actions required by the execution role of the Lambda function | `string` | `""` | no |
| <a name="input_datastore_tags"></a> [datastore\_tags](#input\_datastore\_tags) | Additional tags to add to all datastore resources | `map(string)` | `{}` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The custom domain name for api gateway that points to lambda application | `string` | n/a | yes |
| <a name="input_dynamodb_attributes"></a> [dynamodb\_attributes](#input\_dynamodb\_attributes) | Additional DynamoDB attributes in the form of a list of mapped values | `list` | `[]` | no |
| <a name="input_dynamodb_autoscale_max_read_capacity"></a> [dynamodb\_autoscale\_max\_read\_capacity](#input\_dynamodb\_autoscale\_max\_read\_capacity) | DynamoDB autoscaling max read capacity | `number` | `20` | no |
| <a name="input_dynamodb_autoscale_max_write_capacity"></a> [dynamodb\_autoscale\_max\_write\_capacity](#input\_dynamodb\_autoscale\_max\_write\_capacity) | DynamoDB autoscaling max write capacity | `number` | `20` | no |
| <a name="input_dynamodb_autoscale_min_read_capacity"></a> [dynamodb\_autoscale\_min\_read\_capacity](#input\_dynamodb\_autoscale\_min\_read\_capacity) | DynamoDB autoscaling min read capacity | `number` | `5` | no |
| <a name="input_dynamodb_autoscale_min_write_capacity"></a> [dynamodb\_autoscale\_min\_write\_capacity](#input\_dynamodb\_autoscale\_min\_write\_capacity) | DynamoDB autoscaling min write capacity | `number` | `5` | no |
| <a name="input_dynamodb_autoscale_read_target"></a> [dynamodb\_autoscale\_read\_target](#input\_dynamodb\_autoscale\_read\_target) | The target value (in %) for DynamoDB read autoscaling | `number` | `50` | no |
| <a name="input_dynamodb_autoscale_write_target"></a> [dynamodb\_autoscale\_write\_target](#input\_dynamodb\_autoscale\_write\_target) | The target value (in %) for DynamoDB write autoscaling | `number` | `50` | no |
| <a name="input_dynamodb_billing_mode"></a> [dynamodb\_billing\_mode](#input\_dynamodb\_billing\_mode) | DynamoDB Billing mode. Can be PROVISIONED or PAY\_PER\_REQUEST | `string` | `"PROVISIONED"` | no |
| <a name="input_dynamodb_enable_autoscaler"></a> [dynamodb\_enable\_autoscaler](#input\_dynamodb\_enable\_autoscaler) | Whether or not to enable DynamoDB autoscaling | `bool` | `false` | no |
| <a name="input_dynamodb_enable_encryption"></a> [dynamodb\_enable\_encryption](#input\_dynamodb\_enable\_encryption) | Enable DynamoDB server-side encryption | `bool` | `true` | no |
| <a name="input_dynamodb_enable_point_in_time_recovery"></a> [dynamodb\_enable\_point\_in\_time\_recovery](#input\_dynamodb\_enable\_point\_in\_time\_recovery) | Enable DynamoDB point in time recovery | `bool` | `true` | no |
| <a name="input_dynamodb_enable_streams"></a> [dynamodb\_enable\_streams](#input\_dynamodb\_enable\_streams) | Enable DynamoDB streams | `bool` | `false` | no |
| <a name="input_dynamodb_global_secondary_index_map"></a> [dynamodb\_global\_secondary\_index\_map](#input\_dynamodb\_global\_secondary\_index\_map) | Additional global secondary indexes in the form of a list of mapped values | `any` | `[]` | no |
| <a name="input_dynamodb_hash_key"></a> [dynamodb\_hash\_key](#input\_dynamodb\_hash\_key) | DynamoDB table Hash Key | `string` | `""` | no |
| <a name="input_dynamodb_hash_key_type"></a> [dynamodb\_hash\_key\_type](#input\_dynamodb\_hash\_key\_type) | Hash Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| <a name="input_dynamodb_local_secondary_index_map"></a> [dynamodb\_local\_secondary\_index\_map](#input\_dynamodb\_local\_secondary\_index\_map) | Additional local secondary indexes in the form of a list of mapped values | `list` | `[]` | no |
| <a name="input_dynamodb_range_key"></a> [dynamodb\_range\_key](#input\_dynamodb\_range\_key) | DynamoDB table Range Key | `string` | `""` | no |
| <a name="input_dynamodb_range_key_type"></a> [dynamodb\_range\_key\_type](#input\_dynamodb\_range\_key\_type) | Range Key type, which must be a scalar type: `S`, `N` or `B` for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| <a name="input_dynamodb_stream_view_type"></a> [dynamodb\_stream\_view\_type](#input\_dynamodb\_stream\_view\_type) | When an item in a table is modified, what information is written to the stream | `string` | `""` | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | DynamoDB table name. Must be supplied if creating a dynamodb table | `string` | `""` | no |
| <a name="input_dynamodb_tags"></a> [dynamodb\_tags](#input\_dynamodb\_tags) | Additional tags (e.g map(`BusinessUnit`,`XYX`) | `map` | `{}` | no |
| <a name="input_dynamodb_ttl_attribute"></a> [dynamodb\_ttl\_attribute](#input\_dynamodb\_ttl\_attribute) | DynamoDB table ttl attribute | `string` | `"Expires"` | no |
| <a name="input_dynamodb_ttl_enabled"></a> [dynamodb\_ttl\_enabled](#input\_dynamodb\_ttl\_enabled) | Whether ttl is enabled or disabled | `bool` | `true` | no |
| <a name="input_enable_api_gateway"></a> [enable\_api\_gateway](#input\_enable\_api\_gateway) | Allow to create api-gateway | `bool` | `false` | no |
| <a name="input_enable_datastore_module"></a> [enable\_datastore\_module](#input\_enable\_datastore\_module) | Enables the data store module that can provision data storage resources | `bool` | `false` | no |
| <a name="input_internal_entrypoint_config"></a> [internal\_entrypoint\_config](#input\_internal\_entrypoint\_config) | Map of configurations of internal entrypoints. | `map(any)` | n/a | yes |
| <a name="input_lambda_functions_config"></a> [lambda\_functions\_config](#input\_lambda\_functions\_config) | Map of functions and associated configurations. | `map(any)` | n/a | yes |
| <a name="input_layer_artifact_key"></a> [layer\_artifact\_key](#input\_layer\_artifact\_key) | File name key of the layer artifact to load. | `string` | `""` | no |
| <a name="input_msk_arn"></a> [msk\_arn](#input\_msk\_arn) | the MSK source arn for all lambda requires MSK | `string` | `""` | no |
| <a name="input_msk_event_source_config"></a> [msk\_event\_source\_config](#input\_msk\_event\_source\_config) | Map of configurations of MSK event source for each lambda | `map(any)` | `{}` | no |
| <a name="input_parameter_store_path"></a> [parameter\_store\_path](#input\_parameter\_store\_path) | SSM parameter path | `string` | n/a | yes |
| <a name="input_rds_allocated_storage"></a> [rds\_allocated\_storage](#input\_rds\_allocated\_storage) | Amount of storage allocated to RDS instance | `number` | `10` | no |
| <a name="input_rds_database_name"></a> [rds\_database\_name](#input\_rds\_database\_name) | The database name. Can only contain alphanumeric characters and cannot be a database reserved word | `string` | `""` | no |
| <a name="input_rds_enable_performance_insights"></a> [rds\_enable\_performance\_insights](#input\_rds\_enable\_performance\_insights) | Controls the enabling of RDS Performance insights. Default to `true` | `bool` | `true` | no |
| <a name="input_rds_enable_storage_encryption"></a> [rds\_enable\_storage\_encryption](#input\_rds\_enable\_storage\_encryption) | Specifies whether the DB instance is encrypted | `bool` | `false` | no |
| <a name="input_rds_engine"></a> [rds\_engine](#input\_rds\_engine) | The Database engine for the rds instance | `string` | `"postgres"` | no |
| <a name="input_rds_engine_version"></a> [rds\_engine\_version](#input\_rds\_engine\_version) | The version of the database engine | `number` | `11.4` | no |
| <a name="input_rds_identifier"></a> [rds\_identifier](#input\_rds\_identifier) | Identifier of rds instance | `string` | `""` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | The instance type to use | `string` | `"db.t3.small"` | no |
| <a name="input_rds_iops"></a> [rds\_iops](#input\_rds\_iops) | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1' | `number` | `0` | no |
| <a name="input_rds_max_allocated_storage"></a> [rds\_max\_allocated\_storage](#input\_rds\_max\_allocated\_storage) | The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to `allocated_storage` or `0` to disable Storage Autoscaling. | `number` | `0` | no |
| <a name="input_rds_monitoring_interval"></a> [rds\_monitoring\_interval](#input\_rds\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `0` | no |
| <a name="input_rds_monitoring_role_arn"></a> [rds\_monitoring\_role\_arn](#input\_rds\_monitoring\_role\_arn) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring\_interval is non-zero. | `string` | `""` | no |
| <a name="input_rds_password"></a> [rds\_password](#input\_rds\_password) | RDS database password | `string` | `""` | no |
| <a name="input_rds_security_group_ids"></a> [rds\_security\_group\_ids](#input\_rds\_security\_group\_ids) | A List of security groups to bind to the rds instance | `list(string)` | `[]` | no |
| <a name="input_rds_storage_encryption_kms_key_arn"></a> [rds\_storage\_encryption\_kms\_key\_arn](#input\_rds\_storage\_encryption\_kms\_key\_arn) | The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage\_encrypted is set to true and kms\_key\_id is not specified the default KMS key created in your account will be used | `string` | `""` | no |
| <a name="input_rds_subnet_group"></a> [rds\_subnet\_group](#input\_rds\_subnet\_group) | Subnet group for RDS instances | `string` | `""` | no |
| <a name="input_rds_tags"></a> [rds\_tags](#input\_rds\_tags) | Additional tags for the RDS instance | `map(string)` | `{}` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the bucket | `string` | `""` | no |
| <a name="input_s3_bucket_namespace"></a> [s3\_bucket\_namespace](#input\_s3\_bucket\_namespace) | The namespace of the bucket - intention is to help avoid naming collisions | `string` | `""` | no |
| <a name="input_s3_enable_versioning"></a> [s3\_enable\_versioning](#input\_s3\_enable\_versioning) | If versioning should be configured on the bucket | `bool` | `true` | no |
| <a name="input_s3_tags"></a> [s3\_tags](#input\_s3\_tags) | Additional tags to be added to the s3 resources | `map` | `{}` | no |
| <a name="input_ssm_kms_key_arn"></a> [ssm\_kms\_key\_arn](#input\_ssm\_kms\_key\_arn) | KMS key arn | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags that are added to all resources in this module. | `map` | `{}` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs associated with the Lambda function | `list(string)` | `[]` | no |
| <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids) | List of subnet IDs associated with the Lambda function | `list(string)` | `[]` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route 53 hosted zone id | `string` | n/a | yes |

## Outputs

No outputs.
