variable "name" {
  description = "Project Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC id where to deploy platform."
  type        = string
}

variable "service_discovery" {
  description = "Provides a Service Discovery Private DNS Namespace resource."
  type        = string
}

variable "listener_arn" {
  description = "(Required, Forces New Resource) The ARN of the listener to which to attach the rule."
  type        = string
}
