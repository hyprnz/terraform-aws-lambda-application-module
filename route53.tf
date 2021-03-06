resource "aws_apigatewayv2_domain_name" "api_gateway_domain" {
  count       = var.enable_api_gateway ? 1 : 0
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert[0].arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge({ Name = format("%s-%s", var.application_name, "api_gateway_domain") }, { "Lambda Application" = var.application_name }, var.tags)

  depends_on = [aws_acm_certificate_validation.cert]
}

resource "aws_route53_record" "api_gateway_live" {
  count   = var.enable_api_gateway ? 1 : 0
  name    = var.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_gateway_domain[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
