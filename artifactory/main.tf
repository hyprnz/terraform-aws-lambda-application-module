locals {
  cross_account_identifiers = [for account in var.cross_account_numbers : format("arn:aws:iam::%s:root", account)]
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
      kms_master_key_id = var.kms_key_id
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.artifactory.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}
