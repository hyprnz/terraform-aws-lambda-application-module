locals {
  has_customer_kms_key = length(var.ssm_kms_key_arn) > 0 ? true : false
}

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
data "aws_iam_policy_document" "ssm_parameters_access" {
  statement {
    sid = "SSMGetAccess"

    effect = "Allow"

    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameter"
    ]

    resources = [
      "arn:aws:ssm:*:*:parameter${var.parameter_store_path}*"
    ]
  }
  statement {
    sid = "SSMPutAccess"

    effect = "Allow"

    actions = [
      "ssm:PutParameter"
    ]

    resources = [
      "arn:aws:ssm:*:*:parameter${var.parameter_store_path}write/*"
    ]
  }
}

data "aws_iam_policy_document" "ssm_kms_key" {
  statement {
    sid    = "KMSAccess"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      var.ssm_kms_key_arn
    ]
  }
}


resource "aws_iam_role" "lambda_application_execution_role" {
  name = "${var.application_name}-LA-ER"
  path = var.iam_resource_path

  description = "Lambda Application Execution Role"

  assume_role_policy = data.aws_iam_policy_document.lambda_application_assume_role_statement.json

  tags = merge({ "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_iam_policy" "event_bridge_internal_entrypoint" {
  name        = "${var.application_name}-LA-EB"
  path        = var.iam_resource_path
  policy      = data.aws_iam_policy_document.event_bridge_internal_entrypoint.json
  description = "Grants permissions to write internal entrypoint events to EventBridge"
}

resource "aws_iam_role_policy_attachment" "lambda_application_logs" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "event_bridge_internal_entrypoint_access" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.event_bridge_internal_entrypoint.arn
}

resource "aws_iam_role_policy_attachment" "datastore_s3_access_policy" {
  count      = var.enable_datastore && var.create_s3_bucket ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = module.lambda_datastore.s3_bucket_policy_arn
}

resource "aws_iam_role_policy_attachment" "datastore_dynamodb_access_policy" {
  count      = var.enable_datastore && var.create_dynamodb_table ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = module.lambda_datastore.dynamodb_table_policy_arn
}

resource "aws_iam_policy" "lambda_vpc" {
  count       = local.vpc_policy_required ? 1 : 0
  name        = "${var.application_name}-LA-VPC"
  path        = var.iam_resource_path
  description = "Grants Lambda Application permissions to access VPC"
  policy      = data.aws_iam_policy_document.lambda_vpc_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count      = local.vpc_policy_required ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.lambda_vpc[0].arn
}

locals {
  enable_msk_integration = length(keys(var.msk_event_source_config)) > 0 ? true : false
}
resource "aws_iam_role_policy_attachment" "msk_access_policy" {
  count      = local.enable_msk_integration ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

data "aws_iam_policy_document" "msk_cluster_access" {
  count = local.enable_msk_integration ? 1 : 0
  statement {
    sid    = "MSKConsumer"
    effect = "Allow"

    actions = [
      "kafka-cluster:Connect",
      "kafka-cluster:DescribeCluster",
      "kafka-cluster:AlterGroup",
      "kafka-cluster:DescribeGroup",
      "kafka-cluster:DescribeTopic",
      "kafka-cluster:ReadData",
      "kafka-cluster:WriteData"
    ]

    resources = [
      "arn:aws:kafka:*:*:cluster/*",
      "arn:aws:kafka:*:*:topic/*",
      "arn:aws:kafka:*:*:group/*"
    ]
  }

  statement {
    sid       = "DescribeVpcConnection"
    effect    = "Allow"
    actions   = ["kafka:DescribeVpcConnection"]
    resources = ["arn:aws:kafka:*:*:vpc-connection/*"]
  }
}

resource "aws_iam_policy" "msk_cluster_access" {
  count = local.enable_msk_integration ? 1 : 0

  name        = "${var.application_name}-LA-MSK"
  path        = var.iam_resource_path
  policy      = data.aws_iam_policy_document.msk_cluster_access[0].json
  description = "Grant Lambda Application permissions to consume/produce messages from/to (cross-account) MSK clusters"
}

resource "aws_iam_role_policy_attachment" "msk_cluster_access" {
  count = local.enable_msk_integration ? 1 : 0

  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.msk_cluster_access[0].arn
}

resource "aws_iam_policy" "ssm_access_policy" {
  name        = "${var.application_name}-LA-SSM"
  path        = var.iam_resource_path
  policy      = data.aws_iam_policy_document.ssm_parameters_access.json
  description = "Grants Lambda Application permissions to access parameters from SSM"
}

resource "aws_iam_role_policy_attachment" "ssm_access" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_policy" "ssm_kms_key" {
  count  = local.has_customer_kms_key ? 1 : 0
  name   = "${var.application_name}-LA-KMS"
  path   = var.iam_resource_path
  policy = data.aws_iam_policy_document.ssm_kms_key.json
  description = "Grants Lambda Application permissions to access keys from KMS"
}

resource "aws_iam_role_policy_attachment" "ssm_kms_key" {
  count      = local.has_customer_kms_key ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.ssm_kms_key[0].arn
}

data "aws_iam_policy" "xray_daemon_write_access" {
  name = "AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "xray_daemon" {
  count      = local.enable_active_tracing ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = data.aws_iam_policy.xray_daemon_write_access.arn
}

data "aws_iam_policy" "lambda_insights" {
  name = "CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "lambda_insights" {
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = data.aws_iam_policy.lambda_insights.arn
}

resource "aws_iam_policy" "custom_lambda_policy" {
  count       = local.custom_policy_required ? 1 : 0
  name        = "${var.application_name}-LA-Custom"
  path        = var.iam_resource_path
  description = var.custom_policy_description
  policy      = var.custom_policy_document
}

resource "aws_iam_role_policy_attachment" "custom_lambda" {
  count      = local.custom_policy_required ? 1 : 0
  role       = aws_iam_role.lambda_application_execution_role.name
  policy_arn = aws_iam_policy.custom_lambda_policy[0].arn
}

resource "aws_iam_role" "api_gateway_execution_role" {
  count = var.enable_api_gateway ? 1 : 0

  name = "${var.application_name}-LA-API-ER"
  path = var.iam_resource_path

  description = "Lambda Application external entrypoint API Gateway execution role"

  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role_policy.json
  inline_policy {}

  tags = merge({ "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_iam_policy" "invoke_lambdas" {
  count = var.enable_api_gateway ? 1 : 0

  name        = "${var.application_name}-LA-API"
  path        = var.iam_resource_path
  policy      = data.aws_iam_policy_document.apigateway_lambda_integration.json
  description = "Grants API Gateway permissions to execute Lambda Application functions"
}

resource "aws_iam_role_policy_attachment" "api_gateway_execution_role_policy_attach" {
  count = var.enable_api_gateway ? 1 : 0

  role       = aws_iam_role.api_gateway_execution_role[0].name
  policy_arn = aws_iam_policy.invoke_lambdas[0].arn
}

data "aws_iam_policy_document" "apigateway_lambda_integration" {
  statement {
    effect = "Allow"

    actions = [
      "lambda:InvokeFunction"
    ]

    resources = tolist([for i in aws_lambda_alias.lambda_application_alias : i.arn])
  }
}

data "aws_iam_policy_document" "apigateway_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}