provider "aws" {
  region = "us-west-2"
}

# Common variables for all tests
variables {
  artifactory_bucket_name = "test-artifactory-bucket"
  application_name       = "test-lambda-app"
  cross_account_numbers = ["987654321012", "123456789012"]
  kms_key_administrators = ["arn:aws:iam::123456789012:role/admin-role"]
  tags = {
    Environment = "test"
    Project     = "lambda-app"
  }
}

# Test case 1: Basic configuration
run "verify_bucket_name" {
  command = plan

  assert {
    condition     = aws_s3_bucket.artifactory.bucket == var.artifactory_bucket_name
    error_message = "Bucket name does not match expected value"
  }
}

run "verify_bucket_tags" {
  command = plan

  assert {
    condition     = alltrue([
      for key, value in var.tags : aws_s3_bucket.artifactory.tags[key] == value
    ])
    error_message = "Bucket tags do not match expected values"
  }
}

# Test case 2: Versioning configuration
run "verify_versioning_enabled" {
  command = plan

  variables {
    enable_versioning = true
  }

  assert {
    condition = alltrue([
      for config in aws_s3_bucket_versioning.this.versioning_configuration : config.status == "Enabled"
    ])
    error_message = "Bucket versioning should be enabled"
  }
}

run "verify_versioning_disabled" {
  command = plan

  variables {
    enable_versioning = false
  }

  assert {
    condition = alltrue([
      for config in aws_s3_bucket_versioning.this.versioning_configuration : config.status == "Disabled"
    ])
    error_message = "Bucket versioning should be disabled"
  }
}

# Test case 3: KMS key creation
run "verify_new_kms_key" {
  command = plan

  variables {
    create_kms_key = true
    kms_key_deletion_window_in_days = 7
  }

  assert {
    condition     = length([for key in aws_kms_key.s3_sse : key if key != null]) > 0
    error_message = "KMS key should be created when create_kms_key is true"
  }
}

run "verify_kms_encryption" {
  command = plan

  variables {
    create_kms_key = true
  }

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : (
        r.apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"
      )
    ])
    error_message = "Server-side encryption should use KMS"
  }
}

# Test case 4: Cross-account access
run "verify_cross_account_policy" {
  command = plan

  assert {
    condition     = length([for policy in aws_s3_bucket_policy.cross_account_policy : policy if policy != null]) > 0
    error_message = "Bucket policy should be created when cross_account_numbers is provided"
  }
}

run "verify_cross_account_identifiers" {
  command = plan

  assert {
    condition = alltrue([
      for account in var.cross_account_numbers : 
      contains(local.cross_account_identifiers, format("arn:aws:iam::%s:root", account))
    ])
    error_message = "Cross-account identifiers should be properly formatted"
  }
}

# Test case 5: Security configurations
run "verify_public_access_block" {
  command = plan

  assert {
    condition = alltrue([
      aws_s3_bucket_public_access_block.this.block_public_acls,
      aws_s3_bucket_public_access_block.this.block_public_policy,
      aws_s3_bucket_public_access_block.this.ignore_public_acls,
      aws_s3_bucket_public_access_block.this.restrict_public_buckets
    ])
    error_message = "Public access block settings should all be enabled"
  }
}

run "verify_bucket_ownership" {
  command = plan

  assert {
    condition = alltrue([
      aws_s3_bucket_acl.this.acl == "private",
      alltrue([
        for rule in aws_s3_bucket_ownership_controls.this.rule :
        rule.object_ownership == "BucketOwnerPreferred"
      ])
    ])
    error_message = "Bucket ownership and ACL settings should be properly configured"
  }
}

# Test case 6: Using existing KMS key
run "verify_no_kms_key_creation" {
  command = plan

  variables {
    create_kms_key = false
    kms_key_arn    = "arn:aws:kms:us-west-2:123456789012:key/mock-existing-key"
  }

  assert {
    condition     = length(aws_kms_key.s3_sse) == 0
    error_message = "No KMS key should be created when using existing key"
  }
}

run "verify_existing_kms_key_usage" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/mock-existing-key"
  }

  assert {
    condition     = local.kms_key_id == var.kms_key_arn
    error_message = "Module should use the provided KMS key ARN"
  }
}

run "verify_bucket_encryption_with_existing_key" {
  command = plan
  
  variables {
    kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/mock-existing-key"
  }

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : (
        r.apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms" &&
        r.apply_server_side_encryption_by_default[0].kms_master_key_id == var.kms_key_arn
      )
    ])
    error_message = "Server-side encryption should use the provided KMS key with aws:kms algorithm"
  }
}

run "verify_bucket_encryption_with_existing_key_and_create_kms_key_is_true" {
  command = plan
  
  variables {
    kms_key_arn = "arn:aws:kms:us-west-2:123456789012:key/mock-existing-key"
    create_kms_key = true
  }

  assert {
    condition     = local.kms_key_id == var.kms_key_arn
    error_message = "Module should use the provided KMS key ARN"
  }

  assert {
    condition     = length(aws_kms_key.s3_sse) == 0
    error_message = "No KMS key should be created when using existing key"
  }

  assert {
    condition = alltrue([
      for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : (
        r.apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms" &&
        r.apply_server_side_encryption_by_default[0].kms_master_key_id == var.kms_key_arn
      )
    ])
    error_message = "Server-side encryption should use the provided KMS key with aws:kms algorithm"
  }
}

# Test case 7: EventBridge notifications
run "verify_eventbridge_notifications_disabled" {
  command = plan

  variables {
    enable_eventbridge_notifications = false
  }

  assert {
    condition     = length(aws_s3_bucket_notification.this) == 0
    error_message = "S3 bucket notification should not be created when enable_eventbridge_notifications is false"
  }
}

run "verify_eventbridge_notifications_enabled" {
  command = plan

  variables {
    enable_eventbridge_notifications = true
  }

  assert {
    condition     = length([for notif in aws_s3_bucket_notification.this : notif if notif != null]) > 0
    error_message = "S3 bucket notification should be created when enable_eventbridge_notifications is true"
  }
}

run "verify_eventbridge_notifications_configured" {
  command = plan

  variables {
    enable_eventbridge_notifications = true
  }

  assert {
    condition = alltrue([
      for notif in aws_s3_bucket_notification.this : notif.eventbridge == true
    ])
    error_message = "EventBridge should be enabled on the bucket notification"
  }
}