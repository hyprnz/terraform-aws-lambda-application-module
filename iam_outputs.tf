output "lambda_application_execution_role_arn" {
  description = "The ARN of the Lambda Application Execution Role"
  value       = aws_iam_role.lambda_application_execution_role.arn
}

output "lambda_application_execution_role_name" {
  description = "The Name of the Lambda Application Execution Role"
  value       = aws_iam_role.lambda_application_execution_role.name
}

output "lambda_application_api_gateway_role_arn" {
  description = "The ARN of the Lambda Application API Gateway Role"
  value       = try(aws_iam_role.api_gateway_execution_role[0].arn, "")
}

output "lambda_application_api_gateway_role_name" {
  description = "The Name of the Lambda Application API Gateway Role"
  value       = try(aws_iam_role.api_gateway_execution_role[0].name, "")
}