# ECS Services Module

Terraform ECS services bootstrap in an existing ECS Cluster. This terraform setup can be used to setup the AWS infrastructure for a dockerized application running on ECS with Fargate launch configuration.

##### Load Balancing
This module supports the use of ALBs and NLBs by accepting the ARN of a Load Balancer Listener
and creating the target group for the service. In order to use Load Balancing, set the `load_balancer_target_groups` variable
with the list of Target Group ARNs that the ECS Service should register with.

##### Service Discovery
Service Discovery is supported by creating a Service Discovery Service via this module and allowing the configuration of the
DNS settings for the service. In order to use Service Discovery, the `enable_service_discovery` input variable must be set
to `true` and the ID of an existing Service Discovery Namespace must be passed in. There are several service discovery
input variables that be adjusted to change the behavior Service Discovery.

##### Auto Scaling
This module supports Auto Scaling via a Target Tracking Policy that can be either set against CPU or Memory utilization. In order
to use Auto Scaling, the `enable_auto_scaling` input variable must be set to `true`. There are multiple auto scaling input
variables that be set to adjust the task scaling.

**Note**: In order to tag ECS Service resources, you must have opted in to the new ARN and Resource ID settings for ECS - if not
the ECS Service will fail to create. If you have not opted in, you can set the `ecs_service_tagging_enabled` input variable
to `false` - which will not tag the ECS Service.

---

![](https://github.com/terraform-module/terraform-aws-ecs-bootstrap/workflows/release/badge.svg)
![](https://github.com/terraform-module/terraform-aws-ecs-bootstrap/workflows/commit-check/badge.svg)
![](https://github.com/terraform-module/terraform-aws-ecs-bootstrap/workflows/labeler/badge.svg)

[![](https://img.shields.io/github/license/terraform-module/terraform-aws-ecs-bootstrap)](https://github.com/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/github/v/tag/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/issues/github/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/github/issues/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/github/issues-closed/terraform-module/terraform-aws-ecs-bootstrap)
[![](https://img.shields.io/github/languages/code-size/terraform-module/terraform-aws-ecs-bootstrap)](https://github.com/terraform-module/terraform-aws-ecs-bootstrap)
[![](https://img.shields.io/github/repo-size/terraform-module/terraform-aws-ecs-bootstrap)](https://github.com/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/github/languages/top/terraform-module/terraform-aws-ecs-bootstrap?color=green&logo=terraform&logoColor=blue)
![](https://img.shields.io/github/commit-activity/m/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/github/contributors/terraform-module/terraform-aws-ecs-bootstrap)
![](https://img.shields.io/github/last-commit/terraform-module/terraform-aws-ecs-bootstrap)
[![Maintenance](https://img.shields.io/badge/Maintenu%3F-oui-green.svg)](https://GitHub.com/terraform-module/terraform-aws-ecs-bootstrap/graphs/commit-activity)
[![GitHub forks](https://img.shields.io/github/forks/terraform-module/terraform-aws-ecs-bootstrap.svg?style=social&label=Fork)](https://github.com/terraform-module/terraform-aws-ecs-bootstrap)

---

## Usage example

IMPORTANT: The master branch is used in source just as an example. In your code, do not pin to master because there may be breaking changes between releases. Instead pin to the release tag (e.g. ?ref=tags/x.y.z) of one of our [latest releases](https://github.com/terraform-module/terraform-aws-ecs-bootstrap/releases).

See `examples` directory for working examples to reference:

```hcl
module "ecs-bootstrap" {
  source  = "terraform-module/ecs-bootstrap/aws"
  version = "~> 1"

  name        = var.proxy.name
  name_prefix = format("%s-%s", var.proxy.name, var.env)
  vpc_id      = local.vpc_id
  create      = local.proxy.create
  tags        = local.proxy.tags
  service     = local.proxy

  cluster_id   = local.cluster_id
  cluster_name = local.cluster_name
  subnets      = local.private_subnets

  lb = {
    create       = local.proxy.create && can(var.proxy["lb_condition_rule"])
    port         = local.proxy.exposed_port
    health_check = local.proxy.health_check
    listener_arn = data.aws_lb_listener._443.arn
    priority     = 1
    lb_rules     = can(local.proxy["lb_condition_rule"]) ? var.proxy.lb_condition_rule : {}
  }

  scaling = {
    create          = local.proxy.max_capacity > local.proxy.min_capacity ? true : false
    create_iam_role = false
    min_capacity    = local.proxy.min_capacity
    max_capacity    = local.proxy.max_capacity
    max_cpu_util    = 60

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }

}

data "aws_lb" "this" {
  name = "${var.name}-alb"
}

data "aws_lb_listener" "_443" {
  load_balancer_arn = data.aws_lb.this.arn
  port              = 443
}

locals {
  proxy = {
    name             = "proxy"
    create           = true
    create_log_group = true
    description      = "Public proxy service to create with task definion and LB attachment"
    visibility       = "public"
    exposed_port     = 80
    health_check = {
      path = "/healtz"
    }
    lb_condition_rule = {
      host_headers = ["*."]
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
```

## Examples

See `examples` directory for working examples to reference

- [Complete ECS](https://github.com/terraform-module/terraform-aws-ecs-bootstrap/tree/master/examples)

## Assumptions

## Available features

- Create/Update ECS tasks
- Create/Update ECS services
- CPU based autoscaling

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_cpu_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_additional_policies_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.task_execution_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [random_string.tg](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | ECS Cluster ARN. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS Cluster name. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Controls if resources should be created (affects nearly all resources) | `bool` | `true` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | IAM actions and resource permissions. | `any` | `{}` | no |
| <a name="input_lb"></a> [lb](#input\_lb) | The Load Balancer configuration for the service. A health block containing health check settings for the ALB target groups. See https://www.terraform.io/docs/providers/aws/r/lb_target_group.html#health_check for defaults. | `any` | `{}` | no |
| <a name="input_log_configuration"></a> [log\_configuration](#input\_log\_configuration) | The log configuration for the service. | `any` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Resource names that do not require prefix | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | The prefix for resource names | `string` | n/a | yes |
| <a name="input_scaling"></a> [scaling](#input\_scaling) | Provides an Application AutoScaling resource management. | `any` | `{}` | no |
| <a name="input_sds"></a> [sds](#input\_sds) | Service Discovery Service resource. | `any` | `{}` | no |
| <a name="input_service"></a> [service](#input\_service) | Managed service to create. | `any` | `{}` | no |
| <a name="input_sg"></a> [sg](#input\_sg) | Security group. | `any` | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | VPC subnets where service to deploy to. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id where to deploy platform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudWatch_log_groups"></a> [cloudWatch\_log\_groups](#output\_cloudWatch\_log\_groups) | CloudWatch log group resources |
| <a name="output_ecs_lb_target_group"></a> [ecs\_lb\_target\_group](#output\_ecs\_lb\_target\_group) | Provides a Target Group resource for use with Load Balancer resources. |
| <a name="output_ecs_service"></a> [ecs\_service](#output\_ecs\_service) | Provides an ECS service resource |
| <a name="output_ecs_task_definition"></a> [ecs\_task\_definition](#output\_ecs\_task\_definition) | A revision of an ECS task definition to be used in aws\_ecs\_service |
| <a name="output_lb_listener_rules"></a> [lb\_listener\_rules](#output\_lb\_listener\_rules) | Load Balancer Listener Rule resources. |
| <a name="output_service_discovery"></a> [service\_discovery](#output\_service\_discovery) | Service Discovery. AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-discovery.html |
| <a name="output_service_security_group"></a> [service\_security\_group](#output\_service\_security\_group) | ID of the service security group |
| <a name="output_task_execution_role"></a> [task\_execution\_role](#output\_task\_execution\_role) | Provides an IAM roles. AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html |
| <a name="output_task_role"></a> [task\_role](#output\_task\_role) | Provides an IAM task roles. AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


### :memo: Guidelines

 - :memo: Use a succinct title and description.
 - :bug: Bugs & feature requests can be be opened
 - :signal_strength: Support questions are better asked on [Stack Overflow](https://stackoverflow.com/)
 - :blush: Be nice, civil and polite ([as always](http://contributor-covenant.org/version/1/4/)).

## License

Copyright 2019 Ivan Katliarhcuk

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## How to Contribute

Submit a pull request

# Authors

Currently maintained by [Ivan Katliarchuk](https://github.com/ivankatliarchuk) and these [awesome contributors](https://github.com/terraform-module/terraform-aws-ecs-bootstrap/graphs/contributors).

[![ForTheBadge uses-git](http://ForTheBadge.com/images/badges/uses-git.svg)](https://GitHub.com/)

## Terraform Registry

- [Module](https://registry.terraform.io/modules/terraform-module/ecs-bootstrap/aws)

## Resources

- [AWS: app mesh workshop](https://ecsworkshop.com/networking_sd/app_mesh/)
- [TFLint Rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules)
- [Terraform modules](https://registry.terraform.io/namespaces/terraform-module)
- [Blog: ECS with Fargate and Terraform](https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/)
- [Tfm: example](https://github.com/finleap/tf-ecs-fargate-tmpl)

### Example TFM Modules

- [Tfm: autoscaling](https://github.com/terraform-aws-modules/terraform-aws-autoscaling)
- [Tfm: ecs](https://github.com/terraform-aws-modules/terraform-aws-ecs)
- [Tfm: ecs service](https://github.com/terra-mod/terraform-aws-ecs-service)
- [Tfm: alb](https://github.com/HDE/terraform-aws-alb)
- [Tfm: ecs fargate](https://github.com/stroeer/terraform-aws-ecs-fargate)
- [Tfm: service discovery](https://ecsworkshop.com/introduction/ecs_basics/servicediscovery/)

## TODO

- [ ] Tags per resource
- [ ] Pass default values
- [ ] Strongly typed objects
- [ ] Basic Alerts
