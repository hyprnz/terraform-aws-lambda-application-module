locals {
  api_gateway_route_config = var.enable_api_gateway ? var.api_gateway_route_config : {}
}
resource "aws_apigatewayv2_api" "this" {
  count         = var.enable_api_gateway ? 1 : 0
  name          = var.application_name
  protocol_type = "HTTP"
  tags          = merge({ "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_apigatewayv2_stage" "default" {
  count       = var.enable_api_gateway ? 1 : 0
  api_id      = aws_apigatewayv2_api.this[0].id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_log_group[0].arn
    format = jsonencode(
      {
        httpMethod     = "$context.httpMethod"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        responseLength = "$context.responseLength"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = local.api_gateway_route_config

  api_id           = aws_apigatewayv2_api.this[0].id
  integration_type = "AWS_PROXY"
  credentials_arn  = aws_iam_role.api_gateway_execution_role[0].arn

  connection_type      = "INTERNET"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda_application[each.key].invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = local.api_gateway_route_config

  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = "ANY /${each.key}/{proxy+}"
  operation_name = each.value.operation_name

  target = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

resource "aws_iam_role" "api_gateway_execution_role" {
  count = var.enable_api_gateway ? 1 : 0

  name = format("ExecutionRole-APIGateway-%s", var.application_name)

  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role_policy.json
  inline_policy {}

  tags = merge({ "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_iam_policy" "invoke_lambdas" {
  count = var.enable_api_gateway ? 1 : 0

  name        = "LambdaApplication-${replace(var.application_name, "/-| |_/", "")}-APIGatewayLambdaExecutionPolicy"
  policy      = data.aws_iam_policy_document.apigateway_lambda_integration.json
  description = "Grants permissions to execute Lambda functions"
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

    resources = tolist([for i in aws_lambda_function.lambda_application : i.arn])
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

resource "aws_cloudwatch_log_group" "api_gateway_log_group" {
  count = var.enable_api_gateway ? 1 : 0

  name              = format("/aws/apigateway/%s", var.application_name)
  retention_in_days = var.aws_cloudwatch_log_group_retention_in_days

  tags = merge({ Name = format("%s", var.application_name) }, { "Lambda Application" = var.application_name }, var.tags)
}

# todo aws_apigatewayv2_authorizer: will be helpful to reduce duplicated work