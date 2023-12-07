variable "msk_arn" {
  type        = string
  description = "the MSK source arn for all lambda requires MSK"
  default     = ""
}

variable "msk_event_source_config" {
  type        = map(any)
  description = "Map of configurations of MSK event source for each lambda"
  default     = {}
}