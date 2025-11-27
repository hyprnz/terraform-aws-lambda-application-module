locals {
  flatten_internal_entrypoint_config = flatten([for function_name, int_entrypoints in var.internal_entrypoint_config :
    [for int_entrypoint in int_entrypoints : merge(int_entrypoint, {
      function_name : function_name,
      function_idx : index(tolist(int_entrypoints), int_entrypoint) })
    ]
  ])

  internal_entrypoint_configs = { for value in local.flatten_internal_entrypoint_config : join("-", [value.function_name, value.function_idx]) => value }

  flatten_external_entrypoint_config = flatten([for function_name, ext_entrypoints in var.external_entrypoint_config :
    [for ext_entrypoint in ext_entrypoints : merge(ext_entrypoint, {
      function_name : function_name,
      function_idx : index(tolist(ext_entrypoints), ext_entrypoint) })
    ]
  ])

  external_entrypoint_configs = { for value in local.flatten_external_entrypoint_config : join("-", [value.function_name, value.function_idx]) => value }
}

# Data sources for external event buses
data "aws_cloudwatch_event_bus" "external" {
  for_each = var.event_bus_config
  name     = each.value
}

resource "aws_cloudwatch_event_bus" "internal" {
  name = var.application_name

  tags = local.tags
}

resource "aws_cloudwatch_event_rule" "internal_entrypoint" {
  for_each = local.internal_entrypoint_configs

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern       = length(each.value.event_pattern_json) > 0 ? each.value.event_pattern_json : null
  schedule_expression = length(each.value.schedule_expression) > 0 ? each.value.schedule_expression : null
  event_bus_name      = length(each.value.schedule_expression) > 0 ? null : aws_cloudwatch_event_bus.internal.name

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "lambda_internal_entrypoint" {
  for_each  = local.internal_entrypoint_configs
  rule      = aws_cloudwatch_event_rule.internal_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.value.function_name].arn

  event_bus_name = length(each.value.schedule_expression) > 0 ? null : aws_cloudwatch_event_bus.internal.name
  lifecycle {
    replace_triggered_by = [
      aws_cloudwatch_event_rule.internal_entrypoint[each.key]
    ]
  }
}

resource "aws_lambda_permission" "internal_entrypoints" {
  for_each = local.internal_entrypoint_configs

  statement_id  = replace(title(each.value.name), "/-| |_/", "")
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application[each.value.function_name].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.internal_entrypoint[each.key].arn
  qualifier     = aws_lambda_alias.lambda_application_alias[each.value.function_name].name
}

##################################
# External Entrypoints
##################################

resource "aws_cloudwatch_event_rule" "external_entrypoint" {
  for_each = local.external_entrypoint_configs

  name        = format("%s-%s", var.application_name, each.value.name)
  description = each.value.description

  event_pattern       = length(each.value.event_pattern_json) > 0 ? each.value.event_pattern_json : null
  schedule_expression = length(each.value.schedule_expression) > 0 ? each.value.schedule_expression : null
  event_bus_name      = each.value.event_bus_name

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "lambda_external_entrypoint" {
  for_each  = local.external_entrypoint_configs
  rule      = aws_cloudwatch_event_rule.external_entrypoint[each.key].name
  target_id = each.value.name
  arn       = aws_lambda_alias.lambda_application_alias[each.value.function_name].arn

  event_bus_name = each.value.event_bus_name
  lifecycle {
    replace_triggered_by = [
      aws_cloudwatch_event_rule.external_entrypoint[each.key]
    ]
  }
}

resource "aws_lambda_permission" "external_entrypoints" {
  for_each = local.external_entrypoint_configs

  statement_id  = replace(title(each.value.name), "/-| |_/", "")
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_application[each.value.function_name].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.external_entrypoint[each.key].arn
  qualifier     = aws_lambda_alias.lambda_application_alias[each.value.function_name].name
}
