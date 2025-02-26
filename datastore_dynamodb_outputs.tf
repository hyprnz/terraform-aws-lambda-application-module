output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.lambda_datastore.dynamodb_table_name
}

output "dynamodb_table_id" {
  description = "DynamoDB table ID"
  value       = module.lambda_datastore.dynamodb_table_id
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = module.lambda_datastore.dynamodb_table_arn
}

output "dynamodb_global_secondary_index_names" {
  description = "DynamoDB secondary index names"
  value       = module.lambda_datastore.dynamodb_global_secondary_index_names
}

output "dynamodb_local_secondary_index_names" {
  description = "DynamoDB local index names"
  value       = module.lambda_datastore.dynamodb_local_secondary_index_names
}

output "dynamodb_table_stream_arn" {
  description = "DynamoDB table stream ARN"
  value       = module.lambda_datastore.dynamodb_table_stream_arn
}

output "dynamodb_table_stream_label" {
  description = "DynamoDB table stream label"
  value       = module.lambda_datastore.dynamodb_table_stream_label
}

output "dynamodb_table_policy_arn" {
  description = "Policy arn to be attached to an execution role defined in the parent module."
  value       = module.lambda_datastore.dynamodb_table_policy_arn
}
