data "aws_iam_policy_document" "lambda_application_assume_role_statement" {
  statement {
    sid = "LambdaApplicationAssumeRole"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "event_bridge_internal_entrypoint" {
  statement {
    sid = "LambdaApplicationInternalEntrypointEventBridgeActions"

    effect = "Allow"

    actions = [
      "events:putEvents"
    ]

    resources = [
      "*"
    ]

  }
}

data "aws_iam_policy_document" "lambda_vpc_document" {
  statement {
    sid = "LambdaVPC"

    effect = "Allow"

    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInstances",
      "ec2:DeleteNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:AttachNetworkInterface"
    ]

    resources = [
      "*"
    ]

  }
}

resource "aws_iam_role" "lambda_application_execution_role" {
  name = format("ExecutionRole-Lambda-%s", var.application_name)

  assume_role_policy = data.aws_iam_policy_document.lambda_application_assume_role_statement.json

  tags = merge({ Name = format("%s-Execution-Role", var.application_name) }, { "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_iam_policy" "event_bridge_internal_entrypoint" {
  name        = "LambdaApplication-${replace(var.application_name, "/-| |_/", "")}-EventBridgeInternalEntrypointPolicy"
  policy      = data.aws_iam_policy_document.event_bridge_internal_entrypoint.json
  description = "Grants permissions to write inernal entrypoint events to EventBridge"
}

resource "aws_iam_role_policy_attachment" "lambda_application_logs" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_default_read_access" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "event_bridge_internal_entrypoint_access" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.event_bridge_internal_entrypoint.arn
}

resource "aws_iam_role_policy_attachment" "datastore_s3_access_policy" {
  count      = var.enable_datastore_module && var.create_s3_bucket ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = module.lambda_datastore.s3_bucket_policy_arn
}

resource "aws_iam_role_policy_attachment" "datastore_dynamodb_access_policy" {
  count      = var.enable_datastore_module && var.create_dynamodb_table ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = module.lambda_datastore.dynamodb_table_policy_arn
}

resource "aws_iam_policy" "lambda_vpc" {
  count       = local.vpc_policy_required ? 1: 0
  name        = "LambdaApplication-${replace(var.application_name, "/-| |_/", "")}-LambdaVPC"
  description = "Grants permissions to access VPC"
  policy      = data.aws_iam_policy_document.lambda_vpc_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = local.vpc_policy_required ? 1: 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.lambda_vpc[0].arn
}

resource "aws_iam_role_policy_attachment" "msk_access_policy" {
  count      = length(keys(var.msk_event_source_config)) > 0 ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}
