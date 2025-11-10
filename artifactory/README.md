# Artifactory Module

Opinionated S3 bucket for storing Lambda deployment artifacts. Designed to work with the parent Terraform AWS Lambda Application module. Build processes store compiled zip payloads organised by servicename/version.

## Overview

This module provides a secure, multi-account compatible S3 bucket for Lambda deployment artifacts. It includes support for:

- Cross-account access policies for non-production and production environments
- Customer-managed or existing KMS encryption
- Versioning control
- Public access blocking and ownership controls
- EventBridge notifications for S3 object events

The bucket is designed to live in a shared services account and grant access to accounts where Lambda functions run.

## Usage

### Basic Configuration

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name          = "my-app"
  artifactory_bucket_name   = "my-app-artifacts"
  cross_account_numbers     = ["123456789012"]
  enable_versioning         = true

  # Optional: Create a customer-managed KMS key
  create_kms_key            = true
  kms_key_administrators    = ["arn:aws:iam::123456789012:role/admin"]
  kms_key_deletion_window_in_days = 7
}
```

### With EventBridge Notifications

When `enable_eventbridge_notifications` is set to `true`, the module will enable S3 event notifications to be sent to EventBridge. This allows you to create EventBridge rules in your application module to trigger Lambda functions or other actions based on S3 object events.

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name                 = "my-app"
  artifactory_bucket_name          = "my-app-artifacts"
  cross_account_numbers            = ["123456789012"]
  enable_versioning                = true
  enable_eventbridge_notifications = true
}
```

Once enabled, you can create EventBridge rules to filter and route S3 object events. For example:

```hcl
resource "aws_cloudwatch_event_rule" "artifact_uploaded" {
  name        = "artifact-uploaded"
  description = "Triggers when artifacts are uploaded to S3"
  event_bus_name = "default"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [module.artifactory.bucket_name]
      }
      object = {
        key = [{
          prefix = "artifacts/"
        }]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "my_lambda" {
  rule     = aws_cloudwatch_event_rule.artifact_uploaded.name
  arn      = aws_lambda_function.my_function.arn
  role_arn = aws_iam_role.eventbridge_invoke_lambda.arn
}
```

### With Lifecycle Configuration

Use lifecycle rules to manage artifact retention, optimize storage costs, and clean up incomplete uploads.

#### Example: Delete old artifact versions

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name        = "my-app"
  artifactory_bucket_name = "my-app-artifacts"
  cross_account_numbers   = ["123456789012"]
  enable_versioning       = true

  bucket_lifecycle_rules = [
    {
      id     = "delete-old-versions"
      status = "Enabled"

      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
}
```

#### Example: Transition to Glacier for cost savings

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name        = "my-app"
  artifactory_bucket_name = "my-app-artifacts"
  cross_account_numbers   = ["123456789012"]
  enable_versioning       = true

  bucket_lifecycle_rules = [
    {
      id     = "archive-old-artifacts"
      status = "Enabled"

      filter = {
        prefix = "releases/"
      }

      transitions = [
        {
          days          = 30
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_transitions = [
        {
          days          = 7
          storage_class = "DEEP_ARCHIVE"
        }
      ]
    }
  ]
}
```

#### Example: Clean up incomplete multipart uploads

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name        = "my-app"
  artifactory_bucket_name = "my-app-artifacts"
  cross_account_numbers   = ["123456789012"]

  bucket_lifecycle_rules = [
    {
      id     = "cleanup-incomplete-uploads"
      status = "Enabled"

      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  ]
}
```

#### Example: Filter rules by object size

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name        = "my-app"
  artifactory_bucket_name = "my-app-artifacts"
  cross_account_numbers   = ["123456789012"]
  enable_versioning       = true

  bucket_lifecycle_rules = [
    {
      id     = "archive-large-files"
      status = "Enabled"

      filter = {
        object_size_greater_than = 1073741824  # 1 GB
      }

      transitions = [
        {
          days          = 7
          storage_class = "GLACIER"
        }
      ]
    }
  ]
}
```

#### Example: Filter by multiple conditions (prefix and tags)

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v4.10.0"

  application_name        = "my-app"
  artifactory_bucket_name = "my-app-artifacts"
  cross_account_numbers   = ["123456789012"]
  enable_versioning       = true

  bucket_lifecycle_rules = [
    {
      id     = "expire-tagged-logs"
      status = "Enabled"

      filter = {
        prefix = "logs/"
        tags = {
          Type      = "log"
          Retention = "short"
        }
      }

      expiration = {
        days = 30
      }
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.artifactory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.cross_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_notification.eventbridge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_kms_key.s3_sse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_alias.s3_sse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_name | The name of the Lambda Application. Used to tag artifactory bucket. | `string` | n/a | yes |
| artifactory_bucket_name | The name of the S3 bucket used to store deployment artifacts for the Lambda Application. | `string` | n/a | yes |
| cross_account_numbers | Additional AWS accounts to provide access from. If no account IDs are supplied, no policy is created for the bucket. | `list(string)` | `[]` | no |
| create_kms_key | Controls if a customer-managed KMS key should be provisioned and used for SSE for the bucket. `kms_key_arn` will take precedence if provided. | `bool` | `false` | no |
| enable_eventbridge_notifications | Enable S3 event notifications to EventBridge. When enabled, S3 object events will be automatically sent to the default EventBridge event bus. | `bool` | `false` | no |
| enable_versioning | Enable versioning for the bucket. | `bool` | `true` | no |
| force_destroy | Controls if all objects in a bucket should be deleted when destroying the bucket resource. If set to `false`, the bucket resource cannot be destroyed until all objects are deleted. | `bool` | `false` | no |
| kms_key_administrators | A list of administrator role ARNs that manage the SSE key. Required if `create_kms_key` is `true`. | `list(string)` | `[]` | no |
| kms_key_arn | AWS KMS key ARN used for SSE-KMS encryption of the bucket. Will override `create_kms_key` if value is not null. | `string` | `null` | no |
| kms_key_deletion_window_in_days | Duration in days after which the key is deleted after destruction of the resource. Must be between 7 and 30 days. | `number` | `30` | no |
| kms_key_key_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms that the key supports. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| bucket_lifecycle_rules | List of lifecycle rules for the S3 bucket. Each rule must have an 'id' and 'status'. Rules can include expiration, transitions, and noncurrent version handling. Transitions require S3 versioning to be enabled. | `list(object({...}))` | `[]` | no |
| tags | A map of additional tags to add to the artifactory resource. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | The name of the S3 artifactory bucket. |
| bucket_arn | The ARN of the artifactory bucket. |
| eventbridge_notifications_enabled | Whether EventBridge notifications are enabled for the bucket. |
| lifecycle_configuration_enabled | Whether lifecycle configuration rules are enabled for the bucket. |

## License

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

See [LICENSE](LICENSE) for full details.

```text
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
