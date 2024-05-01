# Terraform AWS Lambda Application Artifactory module

The Artifactory bucket is where the build process can store build artifacts and the key then provided as configuration variable to the Lambda functions. The current use case has the build artifact contains all functions, of which the handler config is the namespace, filename, method name composite.

<!-- BEGIN_TF_DOCS -->
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_name | The name of the Lambda Application. Used to tag artifactory bucket | `string` | n/a | yes |
| artifactory_bucket_name | The name of the S3 bucket used to store deployment artifacts for the Lambda Application | `any` | n/a | yes |
| cross_account_numbers | Additional AWS accounts to provide access from. If no account ID's are supplied no policy is created for the bucket. | `list(number)` | `[]` | no |
| enable_versioning | Determine if versioning is enabled for the bucket. | `bool` | `false` | no |
| force_destroy | Controls if all objects in a bucket should be deleted when destroying the bucket resource. If set to `false`, the bucket resource cannot be destroyed until all objects are deleted. Defaults to `false`. | `bool` | `false` | no |
| kms_key_id | AWS KMS key ID used for the SSE-KMS encryption of the bucket. | `string` | `null` | no |
| tags | A map of additional tags to add to the artifactory resource. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | The name of the artifactory bucket |

---

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
<!-- END_TF_DOCS -->