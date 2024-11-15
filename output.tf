output "lambda_function_arns" {
  description = "ARNs of the Lambda functions"
  value = {
    for function_key, lambda_function in aws_lambda_function.lambda_application :
    function_key => lambda_function.arn
  }
}

output "lambda_function_names" {
  description = "Names of the Lambda functions"
  value = {
    for function_key, lambda_function in aws_lambda_function.lambda_application :
    function_key => lambda_function.function_name
  }
}

output "lambda_function_alias_arns" {
  description = "ARNs of the Lambda function aliases"
  value = {
    for function_key, lambda_function_alias in aws_lambda_alias.lambda_application_alias :
    function_key => lambda_function_alias.arn
  }
}
