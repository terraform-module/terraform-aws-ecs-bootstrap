resource "aws_ecs_task_definition" "this" {
  count = try(var.service.create, false) ? 1 : 0

  family                   = try(var.service.family, format("%s-task", var.name_prefix))
  network_mode             = try(var.service.network_mode, local.defaults.network_mode)
  requires_compatibilities = try(var.service.compatibilities, [local.defaults.compatibilities])
  cpu                      = try(var.service.cpu, local.defaults.cpu)
  memory                   = try(var.service.memory, local.defaults.memory)
  execution_role_arn       = aws_iam_role.task_execution_role[0].arn
  task_role_arn            = aws_iam_role.task_role[0].arn
  container_definitions    = jsonencode(var.service.container_definitions)

  tags = merge(var.tags, {
    Name = format("%s-task", var.name_prefix)
  })
}

resource "aws_ecs_service" "this" {
  count = try(var.service.create, false) ? 1 : 0

  name                               = local.service_name
  cluster                            = local.cluster_id
  task_definition                    = aws_ecs_task_definition.this[count.index].family
  desired_count                      = try(var.service.desired_count, local.defaults.desired_count)
  deployment_minimum_healthy_percent = try(var.service.deployment_minimum_healthy_percent, local.defaults.deployment_minimum_healthy_percent)
  deployment_maximum_percent         = try(var.service.deployment_maximum_percent, local.defaults.deployment_maximum_percent)
  # InvalidParameterException: Health check grace period is only valid for services configured to use load balancers
  health_check_grace_period_seconds = try(var.lb.create, false) ? try(var.service.health_check_grace_period_seconds, local.defaults.health_check_grace_period_seconds) : null
  enable_execute_command            = local.defaults.enable_execute_command
  launch_type                       = local.defaults.compatibilities
  scheduling_strategy               = try(var.service.scheduling_strategy, local.defaults.scheduling_strategy)

  network_configuration {
    security_groups = aws_security_group.this.*.id
    subnets         = var.subnets
  }

  dynamic "service_registries" {
    for_each = var.service.visibility == "private" ? { for k, v in aws_service_discovery_service.this : k => v } : {}
    content {
      registry_arn = service_registries.value.arn
    }
  }

  dynamic "load_balancer" {
    for_each = try(var.lb.create, false) ? aws_lb_target_group.this : []

    content {
      target_group_arn = load_balancer.value.arn
      container_name   = var.service.container_definitions[count.index].name
      container_port   = var.service.exposed_port
    }
  }

  tags = merge(var.tags, {
    Name = local.service_name
  })

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_service_discovery_service.this
  ]

  # Optional: Allow external changes without Terraform plan difference
  # we ignore task_definition changes as the revision changes on deploy
  # of a new version of the application
  # desired_count is ignored as it can change due to autoscaling policy
  lifecycle {
    ignore_changes = [desired_count]
  }
}
