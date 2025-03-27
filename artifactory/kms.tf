data "aws_iam_policy_document" "sse_kms_key" {
  statement {
    sid = "Cross account Lambda access"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = local.cross_account_identifiers
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = [ "*" ]
  }

  statement {
    sid = "Administrator Access"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = var.kms_key_administrators
    }
    actions = [
      "kms:Create*",
      "kms:Decrypt",
      "kms:Describe*",
      "kms:Enable*",
      "kms:Encrypt",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:ReEncrypt*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:GenerateDataKey*"
    ]
    resources = [ "*" ]
  }
}

resource "aws_kms_key" "s3_sse" {
  count = local.kms_key_count

  description              = "Lambda artifactory bucket SSE Key that supports cross account access."
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  customer_master_key_spec = var.kms_key_key_spec
  policy                   = data.aws_iam_policy_document.sse_kms_key.json
}

resource "aws_kms_alias" "s3_sse" {
  count = local.kms_key_count

  name          = "alias/${var.artifactory_bucket_name}"
  target_key_id = aws_kms_key.s3_sse[0].id
}