variable "name" {
  description = "Resource names that do not require prefix"
  type        = string
}

variable "name_prefix" {
  description = "The prefix for resource names"
  type        = string
}

variable "sds" {
  description = "Service Discovery Service resource."
  type        = any
  default     = {}
}

variable "sg" {
  description = "Security group."
  type        = any
  default     = {}
}

variable "log_configuration" {
  description = "The log configuration for the service."
  type        = any
  default     = {}
}

variable "lb" {
  description = "The Load Balancer configuration for the service. A health block containing health check settings for the ALB target groups. See https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#health_check for defaults."
  type        = any
  default     = {}

  validation {
    condition = alltrue([
      length(var.lb.lb_rules.host_headers) <= 5
    ])
    error_message = "A rule can only have '5' condition values."
  }

  validation {
    condition = alltrue([
      for k, v in var.lb.lb_rules.host_headers : v != "" || v != null || v != "*"
    ])
    error_message = "Invalid host header e.g. *, empty or null for service."
  }
}

variable "iam" {
  description = "IAM actions and resource permissions."
  type        = any
  default     = {}
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC id where to deploy platform."
  type        = string
}

variable "subnets" {
  description = "VPC subnets where service to deploy to."
  type        = list(string)
}

variable "cluster_id" {
  description = "ECS Cluster ARN."
  type        = string
}

variable "cluster_name" {
  description = "ECS Cluster name."
  type        = string
}

variable "service" {
  description = "Managed service to create."
  type        = any
  default     = {}
}

variable "scaling" {
  description = "Provides an Application AutoScaling resource management."
  type        = any
  default     = {}
}
