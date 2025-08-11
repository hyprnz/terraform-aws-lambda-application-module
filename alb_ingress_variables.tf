
variable "alb_ingress_listener_arn" {
  type        = string
  description = "Listener ARN of ALB"
  default     = ""
}

variable "alb_ingress_config" {
  type = map(object({
    target_group_name = string
    target_group_path = string
  }))
  description = <<-EOT
    Map of configuration options for lambda functions that can be triggered by an
    Application Load Balancer (ALB) external entrypoint.
    target_group_name: Name of the target group to use for the lambda function.
    target_group_path: Path to use for the lambda function.
  EOT
  default     = {}
}