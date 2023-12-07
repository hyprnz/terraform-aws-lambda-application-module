variable "enable_load_balancer" {
  type        = bool
  description = "Allow to create load balancer"
  default     = false
}

variable "service_target_group_name" {
  type        = string
  description = "The service target group attached to application load balancer listener"
  default     = ""
}

variable "service_target_group_path" {
  type        = string
  description = "The target path attached to the service target group"
  default     = ""
}
