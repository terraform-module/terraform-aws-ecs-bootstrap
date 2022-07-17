resource "aws_appautoscaling_target" "this" {
  count = var.create && try(var.scaling.create, false) ? 1 : 0

  resource_id        = format("service/%s/%s", local.cluster_name, local.service_name)
  min_capacity       = var.scaling.min_capacity
  max_capacity       = var.scaling.max_capacity // Will scale out up to X replicas
  role_arn           = try(var.scaling.create_iam_role, false) ? aws_iam_role.autoscaling[count.index].arn : null
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.this]
}

resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count = var.create && try(var.scaling.create, false) ? 1 : 0

  name               = format("%s-%s-cpu-autoscaling", local.cluster_name, local.service_name)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.this[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = try(var.scaling.max_cpu_util, local.defaults.target_value, 60)
    scale_in_cooldown  = try(var.scaling.scale_in_cooldown, local.defaults.scale_in_cooldown, 300)
    scale_out_cooldown = try(var.scaling.scale_out_cooldown, local.defaults.scale_out_cooldown, 300)
  }

  depends_on = [aws_appautoscaling_target.this]
}
