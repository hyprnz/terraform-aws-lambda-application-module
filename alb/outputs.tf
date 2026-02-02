output "load_balancer_id" {
  description = "The ARN of the load balancer(matches arn)"
  value       = aws_alb.alb_lambda.id
}

output "load_balancer_arn" {
  description = "The ARN of the load balancer(matches id)"
  value       = aws_alb.alb_lambda.arn
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics"
  value       = aws_alb.alb_lambda.arn_suffix
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_alb.alb_lambda.dns_name
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider"
  value       = aws_alb.alb_lambda.tags_all
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_alb.alb_lambda.zone_id
}

output "ip_address_type" {
  description = "The IP address type of the load balancer"
  value       = aws_alb.alb_lambda.ip_address_type
}

output "vpc_id" {
  description = "The VPC ID of the load balancer"
  value       = aws_alb.alb_lambda.vpc_id
}

output "security_groups" {
  description = "The security groups assigned to the load balancer"
  value = {
    for sg in aws_alb.alb_lambda.security_groups : sg => sg
  }
}
