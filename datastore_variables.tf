variable "enable_datastore_module" {
  type        = bool
  description = "Enables the data store module that will provision data storage resources"
  default     = true
}

variable "datastore_tags" {
  type        = map(any)
  description = "Tags for all datastore resources"
  default     = {}
}
