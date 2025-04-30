resource "aws_cloudwatch_log_group" "lambda_application_log_group" {
  for_each          = var.lambda_functions_config
  name              = format("/aws/lambda/%s-%s", var.application_name, each.key)
  retention_in_days = var.aws_cloudwatch_log_group_retention_in_days

  tags = local.tags
}