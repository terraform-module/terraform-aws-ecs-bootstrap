resource "aws_security_group" "this" {
  count = var.create && try(var.sg.create, false) ? 1 : 0

  name        = format("%s-sg-task", var.name_prefix)
  vpc_id      = var.vpc_id
  description = "ECS task that will house a container, allowing ingress access only to the port that is exposed by the task."

  tags = merge(var.tags, {
    Name = format("%s-sg-task", var.name_prefix)
  })
}

resource "aws_security_group_rule" "cluster" {
  for_each = { for k, v in var.sg.group_rules : k => v if var.create && var.sg.create }

  # Required
  security_group_id = aws_security_group.this[0].id
  protocol          = each.value.protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  type              = each.value.type

  # Optional
  description      = try(each.value.description, null)
  cidr_blocks      = try(each.value.cidr_blocks, null)
  ipv6_cidr_blocks = try(each.value.ipv6_cidr_blocks, null)
  prefix_list_ids  = try(each.value.prefix_list_ids, [])
  self             = try(each.value.self, null)
}
