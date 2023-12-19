output "api_gateway_endpoint" {
  description = "The `HTTP` endpoint of the v2 API Gateway resource"
  value       = try(aws_apigatewayv2_api.this[0].api_endpoint, "")
}

output "api_gateway_arn" {
  description = "The `ARN` of the v2 API Gateway resource"
  value       = try(aws_apigatewayv2_api.this[0].arn, "")
}

output "api_gateway_id" {
  description = "The ID of the v2 API Gateway resource"
  value       = try(aws_apigatewayv2_api.this[0].id, "")
}

output "api_gateway_name" {
  description = "The name of the v2 API Gateway resource"
  value       = try(aws_apigatewayv2_api.this[0].name, "")
}

output "api_gateway_integration_ids" {
  description = "The ID's of the v2 API Gateway integration resource"
  value       = { for k, v in aws_apigatewayv2_integration.lambda : k => v.id }
}

output "api_gateway_stage_api_id" {
  description = "The API ID of the v2 API Gateway stage resource"
  value       = try(aws_apigatewayv2_stage.default[0].api_id, "")
}

output "api_gateway_stage_invoke_url" {
  description = "The API ID of the v2 API Gateway stage resource"
  value       = try(aws_apigatewayv2_stage.default[0].invoke_url, "")
}

output "domain_id" {
  description = "The ID of the custom domain name used for the v2 API gateway resource"
  value       = try(aws_apigatewayv2_domain_name.api_gateway_domain[0].id, null)
}