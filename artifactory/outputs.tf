output "bucket_name" {
  description = "The name of the artifactory bucket"
  value       = aws_s3_bucket.artifactory.id
}

output "bucket_arn" {
  description = "The ARN of the artifactory bucket"
  value       = aws_s3_bucket.artifactory.arn
}

output "eventbridge_notifications_enabled" {
  description = "Whether EventBridge notifications are enabled for the bucket"
  value       = var.enable_eventbridge_notifications
}
