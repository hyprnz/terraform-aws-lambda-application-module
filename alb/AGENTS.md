# Ancillary Lambda Application ALB Module

## Purpose

This folder contains the HTTPS ingress module, an ancillary module for the Lambda Application module in the repo root.

A child/resource module designed to be referenced from the root module. It provides an ALB resource that allows for HTTPS API requests that uses path-based routing to send requests to the correct Lambda Application service/function.

## Making changes

1. Changes made should not cause unnecessary destroys and recreates e.g. renaming a terraform resource id
2. Should pass all previous tests
3. Should add any new tests as required
4. Might be helpful to provide example or extend existing one

5. **Test and validate**
   ```bash
   cd alb
   # Check formatting first (commit separately from functional changes)
   terraform fmt -check
   # If fmt check fails, stop and fix formatting in a separate commit
   terraform fmt
   git add alb/
   git commit -m "chore(alb): format terraform code"
   git push

   # Then proceed with functional changes
   terraform init
   terraform validate
   terraform test
   ```

   **Tests Overview**: The module includes comprehensive plan-based tests only in `tests/alb.tftest.hcl` covering 18 test cases:
   - ALB basic configuration (name, type, deletion protection)
   - IP address configuration (IPv4, dualstack)
   - HTTP/2 and security header settings
   - Access, connection, and health check logging
   - Listener creation and CORS rules
   - Capacity units and timeout configuration
   - Custom routing headers and security response headers
   - mTLS certificate headers and SSL policy
   - WAF integration and host header preservation
   - X-Forwarded-For header processing

   All tests use `command = plan` to validate resource configuration without requiring infrastructure creation.

6. **Update README**
    - Ensure module information is up to date. Read the ./docs/AGENTS_TERRAFORM_DOCS.md from the repo root for context about the desired content and structure.

## Module Consumption

Implementation teams consume this module in a root module:

```hcl
module "alb" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//alb?ref=v1.0.0"

  application_loadbalancer_name = "my-app-alb"
  vpc_id                        = "vpc-12345678"
  subnet_ids                    = ["subnet-1", "subnet-2"]
  zone_id                       = "Z1234567890ABC"
  domain_name                   = "api.example.com"
  ssl_policy                    = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  cors_config = {
    enabled           = true
    allow_origins     = "*"
    allow_methods     = "GET,POST,OPTIONS"
    allow_headers     = "*"
    expose_headers    = "Content-Length"
    max_age           = 3600
    allow_credentials = false
  }

  enable_access_logs          = true
  access_logs_bucket_name     = "my-app-logs"
}
```

## Versioning Strategy

This repository uses **semantic-release** with **conventional commits** for automated versioning and tagging.

- **Automated versioning**: CI automatically creates version tags based on commit messages
- **Format**: `v<major>.<minor>.<patch>` (e.g., `v1.2.0`)
- **Pinning**: Implementation layer MUST pin to specific version tags (never `main`)

### Conventional Commit Message Format

All commits MUST follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

#### Commit Types and Version Impact

| Type | Description | Version Impact | Example |
|------|-------------|----------------|---------|
| `feat` | New feature | Minor (`v1.1.0` → `v1.2.0`) | `feat(alb): add WAF integration support` |
| `fix` | Bug fix | Patch (`v1.1.0` → `v1.1.1`) | `fix(alb): correct security group attachment` |
| `refactor` | Code refactoring | Patch (`v1.1.0` → `v1.1.1`) | `refactor(alb): simplify listener rule logic` |
| `docs` | Documentation only | No release | `docs(alb): update README` |
| `chore` | Maintenance tasks | No release | `chore: update dependencies` |
| `test` | Add/update tests | No release | `test(alb): add listener rule tests` |
| `ci` | CI configuration | No release | `ci: add terraform validate step` |
| `perf` | Performance improvement | Patch | `perf(alb): optimize access logging` |
| `BREAKING CHANGE` | Breaking change | Major (`v1.0.0` → `v2.0.0`) | See below |

#### Breaking Changes

For breaking changes, use `BREAKING CHANGE:` in the commit footer:

```bash
git commit -m "feat(alb)!: remove deprecated enable_cors variable

BREAKING CHANGE: enable_cors variable has been removed.
Use cors_config instead."
```

Or use `!` after the type/scope:

```bash
git commit -m "feat(alb)!: rename listener_protocol variable to alb_protocol"
```

#### Scope Guidelines

The scope should reference the module or area being changed:

- Module names: `alb`, `msk`, `artifactory`
- Infrastructure: `ci`, `docs`, `bootstrap`

#### Examples

```bash
# New feature (minor version bump)
git commit -m "feat(alb): add support for cross-zone load balancing configuration"

# Bug fix (patch version bump)
git commit -m "fix(alb): correct variable type for subnet_ids to list(string)"

# Breaking change (major version bump)
git commit -m "feat(alb)!: remove deprecated enable_cors variable

BREAKING CHANGE: enable_cors variable has been removed.
Use cors_config instead."

# Refactor (patch version bump)
git commit -m "refactor(alb): simplify listener rule logic"

# Documentation (no release)
git commit -m "docs(alb): add CORS configuration examples"
```



## Additional Documentation

If required to generate a Terraform Docs style README for the module YOU MUST READ `docs/AGENTS_TERRAFORM_DOCS.md` at the repo root