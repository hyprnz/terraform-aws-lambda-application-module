locals {
  create_event_bus = length(keys(var.internal_entrypoint_config)) > 0
}

resource "aws_cloudwatch_event_bus" "internal" {
  count = local.create_event_bus ? 1 : 0

  name = var.application_name

  tags = merge({ Name = var.application_name }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_cloudwatch_event_rule" "internal_entrypoint" {
  for_each = var.internal_entrypoint_config

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern       = contains(keys(each.value), "event_pattern_json") ? jsonencode(each.value.event_pattern_json) : null
  schedule_expression = contains(keys(each.value), "schedule_expression") ? each.value.schedule_expression : null
  event_bus_name      = aws_cloudwatch_event_bus.internal[0].name

  tags = merge({ Name = format("%s-%s", var.application_name, each.value.name) }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = var.internal_entrypoint_config
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.key].arn

  event_bus_name = aws_cloudwatch_event_bus.internal[0].name
  lifecycle {
    replace_triggered_by = [
      aws_cloudwatch_event_rule.internal_entrypoint[each.key]
    ]
  }
}