locals {
  flattened_msk_event_source_configs = flatten([
    for function_name, configs in var.msk_event_source_config : [
      for idx, config in configs :
      merge(
      config, 
      {
        function_name : function_name,
        event_source_arn: coalesce(config.event_source_arn, var.msk_arn),
        consumer_group_id: coalesce(config.consumer_group_id, sha1(join("_", [function_name, coalesce(config.event_source_arn, var.msk_arn), config.topic])))
      })
    ]
  ])
}

resource "aws_lambda_event_source_mapping" "msk_event_source" {
  for_each = { for idx, value in local.flattened_msk_event_source_configs : substr(value.consumer_group_id, 0, 6) => value }

  event_source_arn  = each.value.event_source_arn
  function_name     = aws_lambda_alias.lambda_application_alias[each.value.function_name].arn
  topics            = [each.value.topic]
  starting_position = each.value.starting_position
  batch_size        = each.value.batch_size

  amazon_managed_kafka_event_source_config {
    consumer_group_id = each.value.consumer_group_id
  }
}
