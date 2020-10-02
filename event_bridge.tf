resource "aws_cloudwatch_event_rule" "internal_entrypoint" {
  for_each = local.internal_entrypoint_config

  name        = each.value.name
  description = each.value.description

  event_pattern = each.value.event_pattern_json
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = local.internal_entrypoint_config
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_function.lambda_application[each.key].arn
}