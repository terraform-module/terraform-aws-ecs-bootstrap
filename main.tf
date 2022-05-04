################################################################################
# ECS Resources
################################################################################
resource "aws_ecs_task_definition" "this" {
  for_each = { for k, v in var.services : k => v if v.create }

  family                   = try(each.value.family, "${each.key}-task")
  network_mode             = try(each.value.network_mode, local.defaults.network_mode)
  requires_compatibilities = try(each.value.compatibilities, local.defaults.compatibilities)
  cpu                      = try(each.value.cpu, local.defaults.cpu)
  memory                   = try(each.value.memory, local.defaults.memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role[each.key].arn
  task_role_arn            = aws_iam_role.ecs_task_role[each.key].arn
  container_definitions     = jsonencode(each.value.container_definitions)

  tags = merge(var.tags, try(each.value.tags, null), {
      Name    = format("%s-task", try(each.value.name, each.key))
  })
}
