locals {
  cross_account_identifiers = [for account in var.cross_account_numbers : format("arn:aws:iam::%s:root", account)]
}


resource "aws_s3_bucket" "artifactory" {
  bucket = var.artifactory_bucket_name
  acl = "private"

  force_destroy = var.force_destroy

  tags = merge({ Name = var.artifactory_bucket_name }, { "Lambda Application Name" = var.application_name }, var.tags)

  versioning {
    enabled = true
  }
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
