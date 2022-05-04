output "ecs_task_execution_roles" {
  description = "AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html"
  value       = { for k, v in aws_iam_role.ecs_task_execution_role: k => v }
}

output "ecs_task_roles" {
  description = "AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/userguide/task-iam-roles.html"
  value       = { for k, v in aws_iam_role.ecs_task_role: k => v }
}

output "ecs_task_definitions" {
  description = "A revision of an ECS task definition to be used in aws_ecs_service"
  value       = { for k, v in aws_ecs_task_definition.this: k => v }
}
