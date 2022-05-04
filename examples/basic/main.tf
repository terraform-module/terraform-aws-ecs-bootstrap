locals {
  name = "example-ecs"
  tags = {
    Stack      = "ecs-services"
    GithubRepo = "terraform-aws-ecs"
    GithubOrg  = "terraform-module"
  }

  services = {
    api = {
      create         = true
      description    = "API service"
      tags           = { Name    = "api-task-dev", Service = "api" }
      # task_definition
      network_mode   = "awsvpc"
      compatibilities = ["FARGATE"]
      cpu            = 256
      memory         = 512
      container_definitions = [{
        name        = "api"
        image       = "cloudkats/hello-world-rest:latest"
        essential   = true
        environment = [
          { "name" : "DBPORT", "value" : "5432" },
          { "name" : "PORT", "value" : "3000" },
        ]
        portMappings = [{
          protocol      = "tcp"
          containerPort = 3000
          hostPort      = 3000
        }]
        secrets = [
          { Name : "DBHOST", ValueFrom: "arn:aws:ssm:eu-west-1:01479bc8:parameter/dev/database/host" },
          { Name : "DB", ValueFrom: "arn:aws:ssm:eu-west-1:01479bc8:parameter/dev/database/name" },
          { Name : "DBUSER", ValueFrom: "arn:aws:ssm:eu-west-1:01479bc8:parameter/dev/database/username" },
          { Name : "DBPASS", ValueFrom: "arn:aws:ssm:eu-west-1:01479bc8:parameter/dev/database/password" },
        ]
      }]
    }
  }

}


################################################################################
# ECS Resource Creation
################################################################################

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 3"

  name = local.name

  container_insights = true
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = local.tags
}

module "ecs_services" {
  source  = "terraform-module/blueprint"
  version = "~> 1"

  services = local.services
  tags     = local.tags
}

################################################################################
# IAM Resource Creation
################################################################################

resource "aws_iam_policy" "access_permissions" {
  for_each    = { for k, v in local.services : k => v if v.create }
  name        = "${each.key}-task-permissions"
  description = "Should allow access to the ssm parameters"
  tags        = merge(local.tags, try(each.value.tags, null))

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AccessSecrets",
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameters"
            ],
            "Resource": ["*"]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment_secrets" {
  for_each   = { for k, v in local.services : k => v if v.create }
  role       = module.ecs_services.ecs_task_execution_roles[each.key].name
  policy_arn = aws_iam_policy.access_permissions[each.key].arn
}

################################################################################
# OUTPUTS
################################################################################

output "ecs_task_execution_role_arns" {
  description = "AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html"
  value = { for k, v in module.ecs_services.ecs_task_execution_roles: k => v.arn }
}
