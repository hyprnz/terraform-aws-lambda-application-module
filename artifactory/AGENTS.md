# Ancillary Lambda Application Artifactory Module

## Purpose

This folder contains the Artifactory module, an ancillary module for the Lambda Application module in the repo root.

A child/resource module designed to be referenced from the root module. It provides an S3 bucket with an opinionated design for storing Lambda deployment artifacts in a multi-account AWS landing zone.

## Making changes

1. Changes made should not cause unnecessary destroys and recreates e.g. renaming a terraform resource id
2. Should pass all previous tests
3. Should add any new tests as required
4. Might be helpful to provide example or extend existing one

5. **Test and validate**
   ```bash
   cd artifactory
   terraform init
   terraform validate
   terraform fmt
   terraform test
   ```
6. **Update README**
    - Ensure module information is up to date
  
7. **Commit with conventional commit message**
   - Tags are created automatically by CI using semantic-release
   - Use conventional commit format (see Commit Message Convention below)
   - Example:
     ```bash
     git add artifactory/
     git commit -m "feat(artifactory): add option to configure sending bucket events to EventBridge"
     git push
     ```
   - CI will automatically create and push version tags based on commit types

## Module Consumption

Implementation teams consume this module in a root module:

```hcl
module "artifactory" {
  source = "git::https://github.com/hyprnz/terraform-aws-lambda-application-module//artifactory?ref=v1.0.0"

  application_name          = "my-app"
  artifactory_bucket_name   = "my-app-artifacts"
  cross_account_numbers     = ["123456789012"]
  enable_versioning         = true

  # Optional: Create a customer-managed KMS key
  create_kms_key            = true
  kms_key_administrators    = ["arn:aws:iam::123456789012:role/admin"]
  kms_key_deletion_window_in_days = 7

  # Or use an existing KMS key
  # kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/existing-key-id"
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
| `feat` | New feature | Minor (`v1.1.0` → `v1.2.0`) | `feat(artifactory): add KMS key encryption support` |
| `fix` | Bug fix | Patch (`v1.1.0` → `v1.1.1`) | `fix(artifactory): correct cross-account number validation` |
| `refactor` | Code refactoring | Patch (`v1.1.0` → `v1.1.1`) | `refactor(artifactory): simplify bucket policy logic` |
| `docs` | Documentation only | No release | `docs(artifactory): update README` |
| `chore` | Maintenance tasks | No release | `chore: update dependencies` |
| `test` | Add/update tests | No release | `test(artifactory): add bucket versioning tests` |
| `ci` | CI configuration | No release | `ci: add terraform validate step` |
| `perf` | Performance improvement | Patch | `perf(artifactory): optimize bucket access logging` |
| `BREAKING CHANGE` | Breaking change | Major (`v1.0.0` → `v2.0.0`) | See below |

#### Breaking Changes

For breaking changes, use `BREAKING CHANGE:` in the commit footer:

```bash
git commit -m "feat(artifactory)!: remove deprecated bucket_encryption variable

BREAKING CHANGE: bucket_encryption variable has been removed.
Use kms_key_arn instead."
```

Or use `!` after the type/scope:

```bash
git commit -m "feat(artifactory)!: rename cross_account_numbers variable to cross_account_identifiers"
```

#### Scope Guidelines

The scope should reference the module or area being changed:

- Module names: `artifactory`, `alb`, `msk`
- Infrastructure: `ci`, `docs`, `bootstrap`

#### Examples

```bash
# New feature (minor version bump)
git commit -m "feat(artifactory): add option to configure sending bucket events to EventBridge"

# Bug fix (patch version bump)
git commit -m "fix(artifactory): change cross_account_numbers var to list(string)"

# Breaking change (major version bump)
git commit -m "feat(artifactory)!: remove deprecated bucket_encryption variable

BREAKING CHANGE: bucket_encryption variable has been removed.
Use kms_key_arn instead."

# Refactor (patch version bump)
git commit -m "refactor(artifactory): simplify bucket policy logic"

# Documentation (no release)
git commit -m "docs(artifactory): add multi-account setup examples"
```



## Additional Documentation

If required to generate a Terraform Docs style README for the module YOU MUST READ `docs/AGENTS_TERRAFORM_DOCS.md` at the repo root