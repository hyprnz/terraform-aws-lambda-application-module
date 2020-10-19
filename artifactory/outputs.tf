output "bucket_name" {
  description = "The name of the artifactory bucket"
  value       = aws_s3_bucket.artifactory.id
}
