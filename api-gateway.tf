// to use the api-gateway, a service lambda must in lambda_application
resource "aws_apigatewayv2_api" "this" {
  count         = var.enable_api_gateway ? 1 : 0
  name          = var.application_name
  protocol_type = "HTTP"
  tags          = merge({ Name = format("%s-%s", var.application_name, "api_gateway") }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
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

  tags = merge({ Name = format("%s-Execution-Role", var.application_name) }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.api_gateway_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
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

# resource "aws_lambda_permission" "allow_apigateway" {
#   count         = var.enable_api_gateway ? 1 : 0
#   statement_id  = "AllowExecutionFromApiGateway"
#   action        = "lambda:InvokeFunction"
#   function_name = "${aws_lambda_function.lambda_application["service"].function_name}:${var.alias_name}"
#   principal     = "apigateway.amazonaws.com"
#   source_arn    = "${aws_apigatewayv2_api.api_gateway[0].execution_arn}/*"
# }

# resource "aws_apigatewayv2_api_mapping" "api_gateway_mapping" {
#   count       = var.enable_api_gateway ? 1 : 0
#   api_id      = aws_apigatewayv2_api.api_gateway[0].id
#   domain_name = aws_apigatewayv2_domain_name.api_gateway_domain[0].id
#   stage       = "$default"
# }

# todo aws_apigatewayv2_authorizer: will be helpful to reduce duplicated work