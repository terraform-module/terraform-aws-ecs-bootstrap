resource "random_string" "tg" {
  length  = 3
  special = false

  keepers = {
    # Generate a new pet name each time we switch a port
    lb_port = var.lb.port
  }
}

resource "aws_lb_target_group" "this" {
  count = var.create && try(var.lb.create, false) ? 1 : 0
  # "name" cannot be longer than 32 characters
  name        = substr(format("%s-%s-tg-ecs", var.name_prefix, random_string.tg.id), 0, 32)
  port        = var.lb.port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  deregistration_delay = try(var.lb.deregistration_delay, local.defaults.deregistration_delay)

  dynamic "health_check" {
    iterator = el
    for_each = { for k, v in { onlyone = var.lb.health_check } : k => v }

    content {
      enabled             = lookup(el.value, "enabled", true)
      interval            = lookup(el.value, "interval", 30)
      path                = lookup(el.value, "path", "/")
      port                = lookup(el.value, "port", "traffic-port")
      healthy_threshold   = lookup(el.value, "healthy_threshold", 3)
      unhealthy_threshold = lookup(el.value, "unhealthy_threshold", 2)
      timeout             = lookup(el.value, "timeout", 3)
      protocol            = lookup(el.value, "protocol", "HTTP")
      matcher             = lookup(el.value, "matcher", 200)
    }
  }

  tags = merge(var.tags, {
    Name = format("%s-tg-ecs", var.name_prefix)
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "this" {
  count = var.create && try(var.lb.create, false) ? 1 : 0

  listener_arn = var.lb.listener_arn
  priority     = var.lb.priority

  dynamic "action" {
    for_each = aws_lb_target_group.this

    content {
      type             = "forward"
      target_group_arn = action.value.arn
    }
  }

  dynamic "condition" {
    for_each = var.lb.lb_rules

    content {
      host_header {
        values = formatlist("%s.*", condition.value)
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
