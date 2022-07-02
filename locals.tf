locals {
  cluster_id   = var.cluster_id
  cluster_name = var.cluster_name
  service_name = format("%s-svc", var.name_prefix)

  defaults = {
    cpu    = 256
    memory = 512

    enable_execute_command = true
    deregistration_delay   = 30
    retention_in_days      = 1

    deployment_minimum_healthy_percent = 100
    deployment_maximum_percent         = 200
    health_check_grace_period_seconds  = 10

    compatibilities     = "FARGATE"
    network_mode        = "awsvpc"
    scheduling_strategy = "REPLICA"
  }

  defaults_sds = {
    routing_policy    = "MULTIVALUE"
    failure_threshold = 2
  }

  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
