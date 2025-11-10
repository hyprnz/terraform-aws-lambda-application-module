# Artifactory Module

Opinionated S3 bucket for storing Lambda deployment artifacts. Designed to work with the parent Terraform AWS Lambda Application module. Build processes store compiled zip payloads organised by servicename/version.

## Overview

This module provides a secure, multi-account compatible S3 bucket for Lambda deployment artifacts. It includes support for:

- Cross-account access policies for non-production and production environments
- Customer-managed or existing KMS encryption
- Versioning control
- Public access blocking and ownership controls

The bucket is designed to live in a shared services account and grant access to accounts where Lambda functions run.

## Usage

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=<some-tag>"

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
| [aws_kms_key.s3_sse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_alias.s3_sse](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_name | The name of the Lambda Application. Used to tag artifactory bucket. | `string` | n/a | yes |
| artifactory_bucket_name | The name of the S3 bucket used to store deployment artifacts for the Lambda Application. | `string` | n/a | yes |
| cross_account_numbers | Additional AWS accounts to provide access from. If no account IDs are supplied, no policy is created for the bucket. | `list(string)` | `[]` | no |
| create_kms_key | Controls if a customer-managed KMS key should be provisioned and used for SSE for the bucket. `kms_key_arn` will take precedence if provided. | `bool` | `false` | no |
| enable_versioning | Enable versioning for the bucket. | `bool` | `true` | no |
| force_destroy | Controls if all objects in a bucket should be deleted when destroying the bucket resource. If set to `false`, the bucket resource cannot be destroyed until all objects are deleted. | `bool` | `false` | no |
| kms_key_administrators | A list of administrator role ARNs that manage the SSE key. Required if `create_kms_key` is `true`. | `list(string)` | `[]` | no |
| kms_key_arn | AWS KMS key ARN used for SSE-KMS encryption of the bucket. Will override `create_kms_key` if value is not null. | `string` | `null` | no |
| kms_key_deletion_window_in_days | Duration in days after which the key is deleted after destruction of the resource. Must be between 7 and 30 days. | `number` | `30` | no |
| kms_key_key_spec | Specifies whether the key contains a symmetric key or an asymmetric key pair and the encryption algorithms that the key supports. | `string` | `"SYMMETRIC_DEFAULT"` | no |
| tags | A map of additional tags to add to the artifactory resource. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | The name of the S3 artifactory bucket. |

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
