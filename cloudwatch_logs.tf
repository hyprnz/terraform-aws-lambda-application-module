resource "aws_cloudwatch_log_group" "lambda_application_log_group" {
  for_each          = local.lambda_functions_config
  name              = "/aws/lambda/${format("%s-%s", var.application_name, each.value.name)}"
  retention_in_days = var.aws_cloudwatch_log_group_retention_in_days
}