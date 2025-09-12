# Terraform Lambda Application Module Tests

This directory contains comprehensive test suites for the terraform-aws-lambda-application-module using Terraform's native testing framework.

## Test Structure

The test suite is organized by module components:

### Core Tests
- **[main.tftest.hcl](main.tftest.hcl)** - Core Lambda application functionality, service catalog registration, environment variables, layers, and tracing
- **[iam.tftest.hcl](iam.tftest.hcl)** - IAM roles, policies, and permissions for Lambda execution, VPC, tracing, and datastore access

### Integration Tests
- **[api_gateway.tftest.hcl](api_gateway.tftest.hcl)** - API Gateway v2 (HTTP API), stages, integrations, CORS, custom domains, and logging
- **[alb_ingress.tftest.hcl](alb_ingress.tftest.hcl)** - Application Load Balancer target groups, listeners, and Lambda integrations
- **[msk.tftest.hcl](msk.tftest.hcl)** - MSK (Managed Streaming for Kafka) event source mappings
- **[event_bridge.tftest.hcl](event_bridge.tftest.hcl)** - EventBridge internal bus, rules, and entrypoint configurations

### Supporting Services Tests
- **[acm.tftest.hcl](acm.tftest.hcl)** - SSL/TLS certificate provisioning and DNS validation for custom domains
- **[cloudwatch.tftest.hcl](cloudwatch.tftest.hcl)** - CloudWatch log groups for Lambda functions

### Independent Module Component Tests
- **[artifactory/tests/artifactory.tftest.hcl](../artifactory/tests/artifactory.tftest.hcl)** - S3 artifactory bucket configuration (existing)

## Running Tests

### Prerequisites
- Terraform >= 1.6.0 (required for native testing)
- AWS credentials configured
- Required AWS permissions for creating test resources

### Individual Test Files
Run a specific test file:
```bash
# Core functionality tests
terraform test -filter=tests/main.tftest.hcl

# API Gateway integration tests
terraform test -filter=tests/api_gateway.tftest.hcl

# IAM permissions tests
terraform test -filter=tests/iam.tftest.hcl

# ALB ingress tests
terraform test -filter=tests/alb_ingress.tftest.hcl

# MSK event source tests
terraform test -filter=tests/msk.tftest.hcl

# EventBridge tests
terraform test -filter=tests/event_bridge.tftest.hcl

# ACM certificate tests
terraform test -filter=tests/acm.tftest.hcl

# CloudWatch tests
terraform test -filter=tests/cloudwatch.tftest.hcl
```

### All Tests
Run the complete test suite:
```bash
terraform test
```

### Test with Specific Variables
Pass variables to tests:
```bash
terraform test -filter=tests/main.tftest.hcl -var="application_name=my-test-app"
```



## Test Patterns

### Common Test Structure
Each test file follows this pattern:
```hcl
provider "aws" {
  region = "us-west-2"
}

variables {
  # Common test variables
  application_name    = "test-lambda-app"
  application_runtime = "nodejs18.x"
  # ... other variables
}

run "test_name" {
  command = plan  # or apply

  variables {
    # Test-specific variable overrides
  }

  assert {
    condition     = # test condition
    error_message = "Descriptive error message"
  }
}
```

### Test Categories

#### Resource Creation Tests
- Verify resources are created when enabled
- Verify resources are not created when disabled
- Validate resource naming conventions

#### Configuration Tests
- Test resource properties and configurations
- Validate variable propagation
- Test conditional logic

#### Integration Tests
- Test cross-component dependencies
- Verify environment variable injection
- Test IAM permission assignments

#### Edge Case Tests
- Empty configurations
- Invalid combinations
- Boundary conditions

## Test Coverage

### Main Module Components
- ✅ Lambda function creation and configuration
- ✅ Service Catalog application registration
- ✅ Environment variable management
- ✅ Layer configuration and attachment
- ✅ VPC configuration
- ✅ Tracing configuration

### IAM Components
- ✅ Execution role creation and assume role policy
- ✅ Basic Lambda execution permissions
- ✅ VPC-specific permissions
- ✅ X-Ray tracing permissions
- ✅ EventBridge permissions
- ✅ Parameter Store permissions
- ✅ Datastore permissions (RDS, DynamoDB, S3)
- ✅ Custom policy attachment

### API Gateway Components
- ✅ HTTP API (v2) creation and configuration
- ✅ Stage creation with auto-deploy
- ✅ Lambda integration with AWS_PROXY
- ✅ Route configuration and HTTP methods
- ✅ CORS configuration
- ✅ Custom domain with TLS 1.2
- ✅ Route53 DNS records and aliases
- ✅ API mapping for custom domains
- ✅ CloudWatch log group creation
- ✅ Payload format version configuration

### Datastore Components (Limited Coverage)
- ✅ Default disabled state verification (`main.tftest.hcl`)
- ✅ IAM policy creation/absence (`iam.tftest.hcl`)
- ⚠️  **Note**: Comprehensive datastore testing (RDS, DynamoDB, S3 module integration, environment variable injection, configuration validation) is not currently implemented - the datastore module contains its own tests.

### ALB Ingress Components
- ✅ Target group creation and configuration
- ✅ Lambda target attachments
- ✅ Listener rule configuration
- ✅ Health check settings
- ✅ Lambda permissions for ELB

### MSK Components
- ✅ Event source mapping creation
- ✅ Consumer group configuration
- ✅ Batch size and starting position
- ✅ Multiple event sources per function

### EventBridge Components
- ✅ Internal event bus creation
- ✅ Internal and external entrypoint configurations
- ✅ Event patterns and schedules
- ✅ Lambda permissions and targets
- ✅ Configuration flattening logic

### ACM Components
- ✅ Certificate creation based on custom domain
- ✅ DNS validation configuration
- ✅ Route53 validation records
- ✅ Certificate validation dependencies

### CloudWatch Components
- ✅ Log group creation for all functions
- ✅ Naming convention compliance
- ✅ Retention period configuration
- ✅ Tag propagation

## Best Practices

### Writing Tests
1. **Descriptive Test Names**: Use clear, descriptive names for `run` blocks
2. **Meaningful Error Messages**: Provide specific error messages explaining what should happen
3. **Focused Assertions**: Test one concept per assertion when possible
4. **Variable Overrides**: Use test-specific variable overrides to test different scenarios

### Test Organization
1. **Group Related Tests**: Keep related tests in the same file
2. **Test Both Positive and Negative Cases**: Verify both enabled and disabled scenarios
3. **Test Edge Cases**: Include tests for empty configurations and boundary conditions
4. **Validate Dependencies**: Test cross-component integrations

### Performance Considerations
1. **Use `plan` Command**: Most tests use `terraform plan` to avoid creating real resources
2. **Use `apply` Sparingly**: Only use `terraform apply` when testing runtime behavior
3. **Parallel Execution**: Terraform tests can run in parallel when properly isolated

## Continuous Integration

### GitHub Actions Example
```yaml
name: Terraform Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: "1.6.0"
      - name: Run Terraform Tests
        run: terraform test
        env:
          AWS_DEFAULT_REGION: us-west-2
```

## Troubleshooting

### Common Issues
1. **Provider Not Found**: Ensure AWS provider is properly configured
2. **Permission Errors**: Verify AWS credentials and permissions
3. **Resource Conflicts**: Use unique names across tests
4. **State Issues**: Tests use temporary state; clean up with `terraform test -cleanup`

### Debugging Tests
- Use `terraform test -verbose` for detailed output
- Use `terraform test -filter=<file> -verbose` for specific file debugging
- Add intermediate assertions to isolate issues
- Use `terraform console` to test expressions interactively
- Check for common issues:
  - **Set vs List indexing**: Use `contains()` for sets, not `[0]` indexing
  - **Resource conditionals**: Check that resources exist before accessing attributes
  - **Data source dependencies**: Ensure external resources exist before testing
