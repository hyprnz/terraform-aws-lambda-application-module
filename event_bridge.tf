locals {
  create_event_bus        = var.create_event_bus && length(keys(var.internal_entrypoint_config)) > 0
  internal_event_bus_name = local.create_event_bus ? aws_cloudwatch_event_bus.internal[0].name : null
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
  event_bus_name      = length(lookup(each.value, "schedule_expression", "")) > 0 ? null : local.internal_event_bus_name

  tags = merge({ Name = format("%s-%s", var.application_name, each.value.name) }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = var.internal_entrypoint_config
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.key].arn

  event_bus_name = local.internal_event_bus_name
  lifecycle {
    replace_triggered_by = [
      aws_cloudwatch_event_rule.internal_entrypoint[each.key]
    ]
  }
}

resource "aws_lambda_permission" "internal_entrypoints" {
  for_each = var.internal_entrypoint_config

  statement_id  = replace(title(each.value.name), "/-| |_/", "")
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.internal_entrypoint[each.key].arn
  qualifier     = aws_lambda_alias.lambda_application_alias[each.key].name
}

##################################
# External Entrypoints
##################################

resource "aws_cloudwatch_event_rule" "external_entrypoint" {
  for_each = var.external_entrypoint_config

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern       = contains(keys(each.value), "event_pattern_json") ? jsonencode(each.value.event_pattern_json) : null
  schedule_expression = contains(keys(each.value), "schedule_expression") ? each.value.schedule_expression : null
  event_bus_name      = each.value.event_bus_name

  tags = merge({ Name = format("%s-%s", var.application_name, each.value.name) }, { "Lambda Application" = var.application_name }, { "version" = var.application_version }, var.tags)
}

resource "aws_cloudwatch_event_target" "lambda_external_entrypoint" {
  for_each  = var.external_entrypoint_config
  rule      = aws_cloudwatch_event_rule.external_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.key].arn

  event_bus_name = each.value.event_bus_name
  lifecycle {
    replace_triggered_by = [
      aws_cloudwatch_event_rule.external_entrypoint[each.key]
    ]
  }
}

resource "aws_lambda_permission" "external_entrypoints" {
  for_each = var.external_entrypoint_config

  statement_id  = replace(title(each.value.name), "/-| |_/", "")
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.external_entrypoint[each.key].arn
  qualifier     = aws_lambda_alias.lambda_application_alias[each.key].name
}
