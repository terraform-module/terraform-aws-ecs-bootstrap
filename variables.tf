variable "services" {
  description = "Map of ECS managed services to create."
  type        = any
  default     = {}

  # validation {
  #   condition = alltrue([
  #     for k, v in var.services : can(v["iam_role_additional_policies"]) && length(v.iam_role_additional_policies) > 0)
  #   ])
  #   error_message = "'iam_role_additional_policies' only single policy supported at the mean time."
  # }
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
