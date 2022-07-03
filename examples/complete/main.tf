################################################################################
# ECS Resources
################################################################################
module "ecs" {
  source  = "terraform-module/ecs/aws"
  version = "~> 1"

  name = var.name

  container_insights = false
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy = [
    {
      capacity_provider = "FARGATE_SPOT"
    }
  ]

  tags = merge({ Module = "terraform-module/ecs/aws" })
}

################################################################################
# LB Resources
################################################################################
resource "aws_lb" "this" {
  name     = "${var.name}-alb"
  internal = false

  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnets
  enable_http2       = "true"

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  tags                             = { Service = "alb", AlbType = "application" }
}

resource "aws_security_group" "alb" {
  name   = "${var.name}-sg-alb-${var.env}"
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow internet to access port 80 for redirect."
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow internet to communicate with services over HTTPS."
  }

  egress {
    # TEMP for testing, should be locked to just services protocols
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"] # TODO: make sure only vpc cidr or private sunets cidrs
    description = "Allow internal communitcations."
  }
}
