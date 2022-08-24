resource "aws_cloudwatch_event_rule" "internal_entrypoint" {
  for_each = var.internal_entrypoint_config

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern       = contains(keys(each.value), "event_pattern_json") ? jsonencode(each.value.event_pattern_json) : null
  schedule_expression = contains(keys(each.value), "schedule_expression") ? each.value.schedule_expression : null

  tags = merge({ Name = format("%s-%s", var.application_name, each.value.name) }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = var.internal_entrypoint_config
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.key].arn
}