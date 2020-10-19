resource "aws_cloudwatch_event_rule" "internal_entrypoint" {
  for_each = var.internal_entrypoint_config

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern = jsonencode(each.value.event_pattern_json)

  tags = merge({ Name = format("%s-%s", var.application_name, each.value.name) }, { "Lambda Application" = var.application_name }, var.tags)
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = var.internal_entrypoint_config
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_function.lambda_application[each.key].arn
}