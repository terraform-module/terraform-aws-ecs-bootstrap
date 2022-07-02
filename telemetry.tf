resource "aws_cloudwatch_log_group" "this" {

  for_each = var.log_configuration.log_group_names

  name              = each.value.options.awslogs-group
  retention_in_days = try(var.log_configuration.retention_in_days, local.defaults.retention_in_days)
  tags = merge(try(each.value.tags, null), {
    Name = each.value.options.awslogs-group
  })
}
