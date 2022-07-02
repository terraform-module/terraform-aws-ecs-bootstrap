################################################################################
# SERVICE DISCOVERY
################################################################################
output "service_discovery" {
  description = "Service Discovery. AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html"
  value       = try(aws_service_discovery_service.this[0], "")
}

################################################################################
# MISCELLANEOUS
################################################################################
output "service_security_group" {
  description = "ID of the service security group"
  value       = try(aws_security_group.this[0].id, "")
}

output "cloudWatch_log_groups" {
  description = "CloudWatch log group resources"
  value       = try(aws_cloudwatch_log_group.this, "")
}

################################################################################
# IAM
################################################################################
output "task_execution_role" {
  description = "Provides an IAM roles. AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html"
  value       = try(aws_iam_role.task_execution_role[0], "")
}

output "task_role" {
  description = "Provides an IAM task roles. AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html"
  value       = try(aws_iam_role.task_role[0], "")
}

################################################################################
# ECS
################################################################################
output "ecs_task_definition" {
  description = "A revision of an ECS task definition to be used in aws_ecs_service"
  value       = try(aws_ecs_task_definition.this[0], "")
}

output "ecs_service" {
  description = "Provides an ECS service resource"
  value       = try(aws_ecs_service.this[0], "")
}

output "ecs_lb_target_group" {
  description = "Provides a Target Group resource for use with Load Balancer resources."
  value       = try(aws_lb_target_group.this[0], "")
}

output "lb_listener_rules" {
  description = "Load Balancer Listener Rule resources."
  value       = try(aws_lb_listener_rule.this[0], "")
}
