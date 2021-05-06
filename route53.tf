resource "aws_apigatewayv2_domain_name" "api_gateway_domain" {
  depends_on  = [aws_acm_certificate_validation.cert]
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_route53_record" "api_gateway_live" {
  name    = var.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_apigatewayv2_api_mapping" "api_gateway_mapping" {
  api_id      = aws_apigatewayv2_api.api_gateway[0].id
  domain_name = aws_apigatewayv2_domain_name.api_gateway_domain.id
  stage       = aws_apigatewayv2_stage.api_gateway_stage.id
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway[0].id
  name        = var.stage_name
  auto_deploy = true
}