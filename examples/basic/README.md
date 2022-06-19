# AWS ECS Services Setup

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
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | ~> 3 |
| <a name="module_ecs_services"></a> [ecs\_services](#module\_ecs\_services) | terraform-module/ecs-services/aws | ~> 1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.access_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_policy_attachment_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_task_execution_role_arns"></a> [ecs\_task\_execution\_role\_arns](#output\_ecs\_task\_execution\_role\_arns) | AWS Docs https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
