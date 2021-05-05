// to use the api-gateway, a service lambda must in lambda_application
resource "aws_apigatewayv2_api" "api_gateway" {
  count         = var.enable_api_gateway ? 1 : 0
  name          = var.application_name
  protocol_type = "HTTP"
  route_key     = "$default"
  target        = aws_lambda_function.lambda_application["service"].arn
  tags          = merge({ Name = format("%s-%s", var.application_name, "api_gateway")}, { "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_lambda_permission" "allow_apigateway" {
  count         = var.enable_api_gateway ? 1 : 0
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application["service"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway[0].execution_arn}/*"
}

# todo aws_apigatewayv2_authorizer: will be helpful to reduce duplicated work