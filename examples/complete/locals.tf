locals {
  name = "example-ecs"
  env  = "sandbox"
  tags = {
    Stack      = "ecs-services"
    GithubRepo = "terraform-aws-ecs"
    GithubOrg  = "terraform-module"
  }

  private_subnets = data.aws_subnets.private.ids
  public_subnets  = data.aws_subnets.public.ids
  cluster_id      = data.aws_ecs_cluster.this.id
  cluster_name    = var.name

  proxy = {
    name             = "proxy"
    create           = true
    create_log_group = true
    description      = "Public proxy service"
    visibility       = "public"
    exposed_port     = 80
    health_check = {
      path = "/healtz"
    }
    lb_condition_rule = {
      host_headers = ["*.${local.env}"]
    }
    min_capacity  = 1
    max_capacity  = 2 // Will scale out up to 2 replicas
    desired_count = 1
    cpu           = 256
    memory        = 512
    tags          = { service = "proxy", visibility = "public" }
    container_definitions = [{
      name      = "proxy"
      image     = "cloudkats/hello-world-rest:61fe8342"
      essential = true
      environment = [
        { name : "APP_NAME", value : "proxy" },
        { name : "APP_VISIBILITY", value : "private" },
      ]
      linuxParameters : {
        initProcessEnabled : true
      },
      healthCheck : {
        command : [
          "CMD-SHELL",
          "curl -f http://localhost:80/healthz || exit 1"
        ],
        retries : 3,
        timeout : 5,
        interval : 10,
        startPeriod : 10
      },
      portMappings = [{
        protocol      = "tcp"
        containerPort = 80
        hostPort      = 80
      }]
      secrets = [],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/proxy-dev-task"
          awslogs-stream-prefix = "proxy"
          awslogs-region        = "us-west-2"
        }
      }
    }]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "tag:Visibility"
    values = ["private"]
  }
}

data "aws_ecs_cluster" "this" {
  cluster_name = local.cluster_name
}
