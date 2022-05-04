# This role required is due to the fact that the tasks will be executed “serverless” with the Fargate configuration.
# This means there’s no EC2 instances involved, meaning the permissions that usually go to the EC2 instances have to go somewhere else: the Fargate service. This enables the service to e.g. pull the image from ECR, spin up or deregister tasks etc. AWS provides you with a predefined policy for this, so I just attached this to my role:
resource "aws_iam_role" "ecs_task_execution_role" {
  for_each = { for k, v in var.services : k => v if v.create }

  name = "${each.key}-ecs-task-execution-role"
  tags = merge(var.tags, try(each.value.tags, null))

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

# This role provide permissions what AWS services the task has access to
resource "aws_iam_role" "ecs_task_role" {
  for_each = { for k, v in var.services : k => v if v.create }

  name = "${each.key}-ecs-task-role"
  tags = merge(var.tags, try(each.value.tags, null))

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

  depends_on = [ aws_iam_role.ecs_task_execution_role ]
}

# Why: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  for_each   = { for k, v in aws_iam_role.ecs_task_execution_role: k => v }
  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
