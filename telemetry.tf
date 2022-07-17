# You can set a simple string and ECS will create the CloudWatch log group for you
# or you can create the resource yourself as shown here to better manage retetion, tagging, etc.
# Embedding it into the module is not trivial and therefore it is externalized
# Input parameter
# container_definitions ... {
#   logDriver = "awslogs"
#   options   = {
#     awslogs-group        = "/ecs/NAME-ENV-task"
#     awslogs-region       = "REGION"
#     awslogs-stream-prefix = "NAME"
#   }
# }
resource "aws_cloudwatch_log_group" "this" {

  for_each = { for k, v in var.service.container_definitions : k => v.logConfiguration
  if var.create && v.logConfiguration.logDriver == "awslogs" }

  name              = each.value.options.awslogs-group
  retention_in_days = try(var.log_configuration.retention_in_days, local.defaults.retention_in_days)
  tags = merge(try(each.value.tags, null), {
    Name = each.value.options.awslogs-group
  })
}
