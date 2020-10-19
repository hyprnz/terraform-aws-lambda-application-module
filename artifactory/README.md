# Terraform AWS Lambda Application Artifactory module

The Artifactory bucket is where the build process can store build artifacts and the key then provided as configuration variable to the Lambda functions. The current use case has the build artifact contains all functions, of which the handler config is the namespace, filename, method name composite. This works for the `Python 3.8` runtime.

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| application\_name | The name of the Lambda Application. Used to tag artifactory bucket | `string` | n/a | yes |
| artifactory\_bucket\_name | The name of the S3 bucket used to store deployment artifacts for the Lambda Application | `any` | n/a | yes |
| cross\_account\_numbers | Additional AWS accounts to provide access from. If no account ID's are supplied no policy is created for the bucket. | `list(number)` | `[]` | no |
| force\_destroy | Controls if all objects in a bucket should be deleted when destroying the bucket resource. If set to `false`, the bucket resource cannot be destroyed until all objects are deleted. Defaults to `false`. | `bool` | `false` | no |
| tags | A map of additional tags to add to the artifactory resource. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_name | The name of the artifactory bucket |

