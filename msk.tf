resource "aws_lambda_event_source_mapping" "msk_event_source" {
  for_each = var.msk_event_source_config

  event_source_arn  = each.value.msk_arn
  function_name     = aws_lambda_function[each.key].arn
  topics            = each.value.topics
  starting_position = each.value.starting_position
}
resource "aws_lambda_permission" "msk_lambda_describe_cluster" {
  for_each = var.msk_event_source_config

  statement_id  = replace(title(each.key), "/-| |_/", "") + "msk_describe_cluster"
  action        = "DescribeCluster"
  function_name = aws_lambda_function.lambda_application[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.msk_arn
}

resource "aws_lambda_permission" "msk_lambda_describe_cluster" {
  for_each = var.msk_event_source_config

  statement_id  = replace(title(each.key), "/-| |_/", "") + "msk_describe_cluster"
  action        = "GetBootstrapBrokers"
  function_name = aws_lambda_function.lambda_application[each.key].function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.msk_arn
}
