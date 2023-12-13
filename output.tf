output "domain_id" {
  value = try(aws_apigatewayv2_domain_name.api_gateway_domain[0].id, null)
}

output "api_gateway_endpoint" {
  value = try(aws_apigatewayv2_api.this[0].api_endpoint, null)
}
