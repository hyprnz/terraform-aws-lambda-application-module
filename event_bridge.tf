resource "aws_cloudwatch_event_bus" "internal" {
  name = var.application_name

  tags = local.tags
}

# Data sources for external event buses
data "aws_cloudwatch_event_bus" "external" {
  for_each = var.event_bus_config
  name     = each.value
}

resource "aws_cloudwatch_event_rule" "internal_entrypoint" {
  for_each = var.internal_entrypoint_config

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern       = length(keys(each.value.event_pattern_json)) > 0 ? jsonencode(each.value.event_pattern_json) : null
  schedule_expression = length(each.value.schedule_expression) > 0 ? each.value.schedule_expression : null
  event_bus_name      = length(each.value.schedule_expression) > 0 ? null : aws_cloudwatch_event_bus.internal.name

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = var.internal_entrypoint_config
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.key].arn

  event_bus_name = length(each.value.schedule_expression) > 0 ? null : aws_cloudwatch_event_bus.internal.name
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

  tags = local.tags
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
