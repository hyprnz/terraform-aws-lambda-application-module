locals {
  cross_account_identifiers = [for account in var.cross_account_numbers : format("arn:aws:iam::%s:root", account)]

  kms_key_id = var.kms_key_arn != null ? var.kms_key_arn : try(aws_kms_key.s3_sse[0].arn, null)

  kms_key_count = var.kms_key_arn == null && var.create_kms_key ? 1 : 0
}

#trivy:ignore:AVD-AWS-0089
resource "aws_s3_bucket" "artifactory" {
  bucket = var.artifactory_bucket_name

  force_destroy = var.force_destroy

  tags = merge({ Name = var.artifactory_bucket_name }, { "Lambda Application Name" = var.application_name }, var.tags)
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.artifactory.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cross_account_access_document" {
  statement {
    sid = "LambdaApplicationArtifactoryCrossAccountPermission"

    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]

    resources = [format("%s/*", aws_s3_bucket.artifactory.arn)]

    principals {
      type        = "AWS"
      identifiers = local.cross_account_identifiers
    }
  }
}

resource "aws_s3_bucket_policy" "cross_account_policy" {
  count = length(var.cross_account_numbers) > 0 ? 1 : 0

  bucket = aws_s3_bucket.artifactory.id
  policy = data.aws_iam_policy_document.cross_account_access_document.json
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.artifactory.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.artifactory.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.artifactory.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"

      kms_master_key_id = local.kms_key_id
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.artifactory.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_notification" "this" {
  count = var.enable_eventbridge_notifications ? 1 : 0

  bucket      = aws_s3_bucket.artifactory.id
  eventbridge = true
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(var.bucket_lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.artifactory.id

  dynamic "rule" {
    for_each = var.bucket_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        # Case 1: Multiple tags (with or without other conditions) - use 'and' block
        dynamic "and" {
          for_each = (rule.value.filter != null && rule.value.filter.tags != null && length(rule.value.filter.tags) > 1) ? [1] : []
          content {
            prefix                   = rule.value.filter.prefix
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            tags                     = rule.value.filter.tags
          }
        }

        # Case 2: Prefix + single tag - use 'and' block
        dynamic "and" {
          for_each = (rule.value.filter != null && rule.value.filter.prefix != null && rule.value.filter.tags != null && length(rule.value.filter.tags) == 1) ? [1] : []
          content {
            prefix = rule.value.filter.prefix
            tags   = rule.value.filter.tags
          }
        }

        # Case 3: Prefix + size filter(s) - use 'and' block
        dynamic "and" {
          for_each = (rule.value.filter != null && rule.value.filter.prefix != null &&
            (rule.value.filter.object_size_greater_than != null || rule.value.filter.object_size_less_than != null) &&
          (rule.value.filter.tags == null || length(rule.value.filter.tags) == 0)) ? [1] : []
          content {
            prefix                   = rule.value.filter.prefix
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
          }
        }

        # Case 4: Single tag + size filter(s) - use 'and' block
        dynamic "and" {
          for_each = (rule.value.filter != null && rule.value.filter.prefix == null &&
            rule.value.filter.tags != null && length(rule.value.filter.tags) == 1 &&
          (rule.value.filter.object_size_greater_than != null || rule.value.filter.object_size_less_than != null)) ? [1] : []
          content {
            tags                     = rule.value.filter.tags
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
          }
        }

        # Case 5: Prefix only
        prefix = (rule.value.filter != null && rule.value.filter.prefix != null &&
          (rule.value.filter.tags == null || length(rule.value.filter.tags) == 0) &&
          rule.value.filter.object_size_greater_than == null &&
        rule.value.filter.object_size_less_than == null) ? rule.value.filter.prefix : null

        # Case 6: Single tag only (no prefix or size filters)
        dynamic "tag" {
          for_each = (rule.value.filter != null && rule.value.filter.prefix == null &&
            rule.value.filter.tags != null && length(rule.value.filter.tags) == 1 &&
            rule.value.filter.object_size_greater_than == null &&
          rule.value.filter.object_size_less_than == null) ? rule.value.filter.tags : {}
          content {
            key   = tag.key
            value = tag.value
          }
        }

        # Case 7: object_size_greater_than only
        object_size_greater_than = (rule.value.filter != null && rule.value.filter.object_size_greater_than != null &&
          rule.value.filter.prefix == null &&
          (rule.value.filter.tags == null || length(rule.value.filter.tags) == 0) &&
        rule.value.filter.object_size_less_than == null) ? rule.value.filter.object_size_greater_than : null

        # Case 8: object_size_less_than only
        object_size_less_than = (rule.value.filter != null && rule.value.filter.object_size_less_than != null &&
          rule.value.filter.prefix == null &&
          (rule.value.filter.tags == null || length(rule.value.filter.tags) == 0) &&
        rule.value.filter.object_size_greater_than == null) ? rule.value.filter.object_size_less_than : null

        # Case 9: Both size filters only
        dynamic "and" {
          for_each = (rule.value.filter != null &&
            rule.value.filter.object_size_greater_than != null &&
            rule.value.filter.object_size_less_than != null &&
            rule.value.filter.prefix == null &&
          (rule.value.filter.tags == null || length(rule.value.filter.tags) == 0)) ? [1] : []
          content {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
          }
        }

        # Case 10: Empty filter (no conditions specified)
        dynamic "and" {
          for_each = (rule.value.filter == null || (
            rule.value.filter.prefix == null &&
            (rule.value.filter.tags == null || length(rule.value.filter.tags) == 0) &&
            rule.value.filter.object_size_greater_than == null &&
            rule.value.filter.object_size_less_than == null
          )) ? [1] : []
          content {
          }
        }
      }

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days                         = expiration.value.days
          date                         = expiration.value.date
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions != null ? rule.value.transitions : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions != null ? rule.value.noncurrent_version_transitions : []
        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}
