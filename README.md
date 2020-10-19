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

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| application\_name | Repo name of the lambda application. | `string` | n/a | yes |
| application\_runtime | Lambda runtime for the application. | `string` | n/a | yes |
| artifact\_bucket | Bucket that stores function artifacts. Includes layer dependencies. | `string` | n/a | yes |
| artifact\_bucket\_key | File name key of the artifact to load. | `string` | n/a | yes |
| internal\_entrypoint\_config | Map of configurations of internal entrypoints. | `map(any)` | n/a | yes |
| lambda\_functions\_config | Map of functions and associated configurations. | `map(any)` | n/a | yes |
| application\_env\_vars | Map of environment variables required by any function in the application. | `map(any)` | `{}` | no |
| application\_memory | Memory allocated to all functions in the application. Defaults to `128`. | `number` | `128` | no |
| application\_timeout | Timeout in seconds for all functions in the application. Defaults to `3`. | `number` | `3` | no |
| aws\_cloudwatch\_log\_group\_retention\_in\_days | The retention period in days of all log group created for each function. Defaults to `30`. | `number` | `30` | no |
| create\_dynamodb\_table | Whether or not to enable DynamoDB resources | `bool` | `false` | no |
| create\_rds\_instance | Controls if an RDS instance should be provisioned and integrated with the Kubernetes deployment. | `bool` | `false` | no |
| create\_s3\_bucket | Controls if an S3 bucket should be provisioned | `bool` | `false` | no |
| datastore\_tags | Additional tags to add to all datastore resources | `map(string)` | `{}` | no |
| dynamodb\_attributes | Additional DynamoDB attributes in the form of a list of mapped values | `list` | `[]` | no |
| dynamodb\_autoscale\_max\_read\_capacity | DynamoDB autoscaling max read capacity | `number` | `20` | no |
| dynamodb\_autoscale\_max\_write\_capacity | DynamoDB autoscaling max write capacity | `number` | `20` | no |
| dynamodb\_autoscale\_min\_read\_capacity | DynamoDB autoscaling min read capacity | `number` | `5` | no |
| dynamodb\_autoscale\_min\_write\_capacity | DynamoDB autoscaling min write capacity | `number` | `5` | no |
| dynamodb\_autoscale\_read\_target | The target value (in %) for DynamoDB read autoscaling | `number` | `50` | no |
| dynamodb\_autoscale\_write\_target | The target value (in %) for DynamoDB write autoscaling | `number` | `50` | no |
| dynamodb\_billing\_mode | DynamoDB Billing mode. Can be PROVISIONED or PAY\_PER\_REQUEST | `string` | `"PROVISIONED"` | no |
| dynamodb\_enable\_autoscaler | Whether or not to enable DynamoDB autoscaling | `bool` | `false` | no |
| dynamodb\_enable\_encryption | Enable DynamoDB server-side encryption | `bool` | `true` | no |
| dynamodb\_enable\_point\_in\_time\_recovery | Enable DynamoDB point in time recovery | `bool` | `true` | no |
| dynamodb\_enable\_streams | Enable DynamoDB streams | `bool` | `false` | no |
| dynamodb\_global\_secondary\_index\_map | Additional global secondary indexes in the form of a list of mapped values | `any` | `[]` | no |
| dynamodb\_hash\_key | DynamoDB table Hash Key | `string` | `""` | no |
| dynamodb\_hash\_key\_type | Hash Key type, which must be a scalar type: `S`, `N`, or `B` for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| dynamodb\_local\_secondary\_index\_map | Additional local secondary indexes in the form of a list of mapped values | `list` | `[]` | no |
| dynamodb\_range\_key | DynamoDB table Range Key | `string` | `""` | no |
| dynamodb\_range\_key\_type | Range Key type, which must be a scalar type: `S`, `N` or `B` for (S)tring, (N)umber or (B)inary data | `string` | `"S"` | no |
| dynamodb\_stream\_view\_type | When an item in a table is modified, what information is written to the stream | `string` | `""` | no |
| dynamodb\_table\_name | DynamoDB table name. Must be supplied if creating a dynamodb table | `string` | `""` | no |
| dynamodb\_tags | Additional tags (e.g map(`BusinessUnit`,`XYX`) | `map` | `{}` | no |
| dynamodb\_ttl\_attribute | DynamoDB table ttl attribute | `string` | `"Expires"` | no |
| dynamodb\_ttl\_enabled | Whether ttl is enabled or disabled | `bool` | `true` | no |
| enable\_datastore\_module | Enables the data store module that can provision data storage resources | `bool` | `false` | no |
| layer\_artifact\_key | File name key of the layer artifact to load. | `string` | `""` | no |
| rds\_allocated\_storage | Amount of storage allocated to RDS instance | `number` | `10` | no |
| rds\_database\_name | The database name. Can only contain alphanumeric characters and cannot be a database reserved word | `string` | `""` | no |
| rds\_enable\_performance\_insights | Controls the enabling of RDS Performance insights. Default to `true` | `bool` | `true` | no |
| rds\_enable\_storage\_encryption | Specifies whether the DB instance is encrypted | `bool` | `false` | no |
| rds\_engine | The Database engine for the rds instance | `string` | `"postgres"` | no |
| rds\_engine\_version | The version of the database engine | `number` | `11.4` | no |
| rds\_identifier | Identifier of rds instance | `string` | `""` | no |
| rds\_instance\_class | The instance type to use | `string` | `"db.t3.small"` | no |
| rds\_iops | The amount of provisioned IOPS. Setting this implies a storage\_type of 'io1' | `number` | `0` | no |
| rds\_max\_allocated\_storage | The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Configuring this will automatically ignore differences to `allocated_storage`. Must be greater than or equal to `allocated_storage` or `0` to disable Storage Autoscaling. | `number` | `0` | no |
| rds\_monitoring\_interval | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `0` | no |
| rds\_monitoring\_role\_arn | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Must be specified if monitoring\_interval is non-zero. | `string` | `""` | no |
| rds\_password | RDS database password | `string` | `""` | no |
| rds\_security\_group\_ids | A List of security groups to bind to the rds instance | `list(string)` | `[]` | no |
| rds\_storage\_encryption\_kms\_key\_arn | The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN. If storage\_encrypted is set to true and kms\_key\_id is not specified the default KMS key created in your account will be used | `string` | `""` | no |
| rds\_subnet\_group | Subnet group for RDS instances | `string` | `""` | no |
| rds\_tags | Additional tags for the RDS instance | `map(string)` | `{}` | no |
| s3\_bucket\_name | The name of the bucket | `string` | `""` | no |
| s3\_bucket\_namespace | The namespace of the bucket - intention is to help avoid naming collisions | `string` | `""` | no |
| s3\_enable\_versioning | If versioning should be configured on the bucket | `bool` | `true` | no |
| s3\_tags | Additional tags to be added to the s3 resources | `map` | `{}` | no |
| tags | Additional tags that are added to all resources in this module. | `map` | `{}` | no |

## Outputs

No output.

