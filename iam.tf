################################################################################
# IAM Actions
################################################################################
resource "aws_iam_role" "task_execution_role" {
  count = try(var.iam.create, false) ? 1 : 0
  name  = format("%s-ecs-task-execution-role", var.name_prefix)
  tags  = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task_execution_role_policy_attachment" {
  for_each   = { for k, v in local.iam_role_policies : k => v if var.iam.create }
  role       = aws_iam_role.task_execution_role[0].id
  policy_arn = each.value
}

resource "aws_iam_role" "task_role" {
  count = try(var.iam.create, false) ? 1 : 0
  name  = format("%s-ecs-task-role", var.name_prefix)
  tags  = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  depends_on         = [aws_iam_role.task_execution_role]
}

resource "aws_iam_role_policy" "task_additional_policies_attach" {
  for_each = { for k, v in var.iam.additional_policies : k => v if var.iam.create }

  name   = format("%s-%s-ecs-task-service-permissions", var.name_prefix, each.key)
  role   = aws_iam_role.task_role[0].name
  policy = each.value
}

################################################################################
# ECS Autoscaling
################################################################################
resource "aws_iam_role" "autoscaling" {
  count = try(var.scaling.create, false) && try(var.scaling.create_iam_role, false) ? 1 : 0

  name               = format("%s-appautoscaling-role", local.service_name)
  assume_role_policy = file("${path.module}/templates/autoscaling-role.json")
}

resource "aws_iam_role_policy" "autoscaling" {
  count = try(var.scaling.create, false) && try(var.scaling.create_iam_role, false) ? 1 : 0

  name   = format("%s-appautoscaling-policy", local.service_name)
  policy = file("${path.module}/templates/autoscaling-policy.json")
  role   = aws_iam_role.autoscaling[count.index].id
}
