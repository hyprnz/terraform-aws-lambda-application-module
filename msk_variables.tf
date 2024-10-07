variable "msk_arn" {
  type        = string
  description = "the MSK source arn for all lambda requires MSK"
  default     = ""
}

variable "msk_event_source_config" {
  type = map(set(object({
    event_source_arn         = optional(string, null)
    topic                    = string
    starting_position        = optional(string, "LATEST")
    batch_size               = optional(number, null)
    consumer_group_id_prefix = optional(string, "")
    enabled                  = optional(bool, true)
  })))
  description = "Map of configurations of MSK event source for each lambda"
  default     = {}
}
