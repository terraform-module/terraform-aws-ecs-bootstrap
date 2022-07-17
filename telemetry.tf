resource "aws_cloudwatch_log_group" "this" {

  for_each = { for k, v in var.service.container_definitions : k => v.logConfiguration
  if var.create && v.logConfiguration.logDriver == "awslogs" }

  name              = each.value.options.awslogs-group
  retention_in_days = try(var.log_configuration.retention_in_days, local.defaults.retention_in_days)
  tags = merge(try(each.value.tags, null), {
    Name = each.value.options.awslogs-group
  })
}
