module "ecs-bootstrap-service" {
  source = "../.."

  name        = var.proxy.name
  name_prefix = format("%s-%s", var.proxy.name, var.env)
  vpc_id      = var.vpc_id
  tags        = var.proxy.tags
  service     = var.proxy

  cluster_id   = var.cluster_id
  cluster_name = var.cluster_name
  subnets      = local.subnets

  sds = {
    create       = var.proxy.create && var.proxy.visibility == "private"
    namespace_id = var.service_discovery
  }

  lb = {
    create       = var.proxy.create && can(var.proxy["lb_condition_rule"])
    port         = var.proxy.exposed_port
    health_check = var.proxy.health_check
    listener_arn = var.listener_arn
    priority     = 1
    lb_rules     = can(var.proxy["lb_condition_rule"]) ? var.proxy.lb_condition_rule : {}
  }

  scaling = {
    create          = var.proxy.max_capacity > var.proxy.min_capacity ? true : false
    create_iam_role = false
    min_capacity    = var.proxy.min_capacity
    max_capacity    = var.proxy.max_capacity
    max_cpu_util    = 60

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

  sg = {
    create = var.proxy.create
    group_rules = {
      ingress_exposed = {
        description = "Ingress Exposed to svc"
        protocol    = "tcp"
        from_port   = var.proxy.exposed_port
        to_port     = var.proxy.exposed_port
        type        = "ingress"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress_default = {
        description = "ALLOW ALL egress rule"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "egress"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
  }

  log_configuration = {
    log_group_names = { for k, v in var.proxy.container_definitions : k => v.logConfiguration
    if var.proxy.create && var.proxy.create_log_group && v.logConfiguration.logDriver == "awslogs" }
    retention_in_days = 1
  }

  iam = {
    create = var.proxy.create
    additional_policies = {
      default = templatefile("${path.module}/iam/ecs-task-default.json", {
        env        = var.env
        account_id = local.account_id
      })
    }
  }
}
