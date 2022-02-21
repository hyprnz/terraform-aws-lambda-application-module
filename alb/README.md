<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.31 |
| aws | >= 3.38.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.38.0 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| application_loadbalancer_name | The name of the application load balancer for lambdas | `string` | n/a | yes |
| domain_name | The custom domain name for application load balancer | `string` | n/a | yes |
| subnet_ids | The subnet ids for application load balancer | `any` | n/a | yes |
| vpc_id | The vpc_id that the application load balancer will bind to | `string` | n/a | yes |
| zone_id | Route 53 hosted zone id | `string` | n/a | yes |
| enable_access_logs | Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified. | `bool` | `false` | no |
| logs_bucket_name | The S3 bucket name to store the logs in. | `string` | `""` | no |
| logs_bucket_prefix | The S3 bucket prefix. Logs are stored in the root if not configured. | `string` | `""` | no |
| tags | A map of additional tags to add to the artifactory resource. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn_suffix | The ARN suffix for use with CloudWatch Metrics |
| dns_name | The DNS name of the load balancer |
| load_balancer_arn | The ARN of the load balancer(matches id) |
| load_balancer_id | The ARN of the load balancer(matches arn) |
| tags_all | A map of tags assigned to the resource, including those inherited from the provider |
| zone_id | The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record). |

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