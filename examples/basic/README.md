# AWS ECS Services Setup

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

## Parameters

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs-bootstrap-service"></a> [ecs-bootstrap-service](#module\_ecs-bootstrap-service) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_listener_arn"></a> [listener\_arn](#input\_listener\_arn) | (Required, Forces New Resource) The ARN of the listener to which to attach the rule. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Project Name | `string` | n/a | yes |
| <a name="input_service_discovery"></a> [service\_discovery](#input\_service\_discovery) | Provides a Service Discovery Private DNS Namespace resource. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id where to deploy platform. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
