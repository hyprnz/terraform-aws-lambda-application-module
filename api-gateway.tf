// to use the api-gateway, a service lambda must in lambda_application
resource "aws_apigatewayv2_api" "api-gateway" {
  name          = var.application_name
  protocol_type = "HTTP"
  route_key     = "$default"
  target        = aws_lambda_function.lambda_application["service"].arn
  count         = var.enable_api_gateway ? 1 : 0
}

resource "aws_lambda_permission" "allow_apigateway" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application["service"].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_apigatewayv2_api.api-gateway[0].arn
  count         = var.enable_api_gateway ? 1 : 0
}

# todo aws_apigatewayv2_authorizer: will be helpful to reduce duplicated work
# todo aws_apigatewayv2_domain_name: need domain and cert setup
