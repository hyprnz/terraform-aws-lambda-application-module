// to use the api-gateway, a service lambda must in lambda_application
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
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = var.lambda_functions_config

  api_id           = aws_apigatewayv2_api.this[0].id
  integration_type = "AWS_PROXY"
  credentials_arn  = aws_iam_role.api_gateway_execution_role.arn

  connection_type      = "INTERNET"
  integration_method   = "POST"
  integration_uri      = aws_lambda_function.lambda_application[each.key].invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_iam_role" "api_gateway_execution_role" {
  name = format("ExecutionRole-APIGateway-%s", var.application_name)

  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role_policy.json
  inline_policy {}

  tags = merge({ "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_iam_role_policy_attachment" "api_gateway_execution_role_policy_attach" {
  role       = aws_iam_role.api_gateway_execution_role.name
  policy_arn = aws_iam_policy.invoke_lambdas.arn
}

resource "aws_iam_policy" "invoke_lambdas" {
  name        = "LambdaApplication-${replace(var.application_name, "/-| |_/", "")}-APIGatewayLambdaExecutionPolicy"
  policy      = data.aws_iam_policy_document.apigateway_lambda_integration.json
  description = "Grants permissions to execute Lambda functions"
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


resource "aws_apigatewayv2_route" "lambda" {
  for_each = var.lambda_functions_config

  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = "ANY /${each.key}/{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

# todo aws_apigatewayv2_authorizer: will be helpful to reduce duplicated work