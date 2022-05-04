# ECS Services Module

Terraform module

---

![](https://github.com/terraform-module/terraform-aws-ecs-services/workflows/release/badge.svg)
![](https://github.com/terraform-module/terraform-aws-ecs-services/workflows/commit-check/badge.svg)
![](https://github.com/terraform-module/terraform-aws-ecs-services/workflows/labeler/badge.svg)

[![](https://img.shields.io/github/license/terraform-module/terraform-aws-ecs-services)](https://github.com/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/github/v/tag/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/issues/github/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/github/issues/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/github/issues-closed/terraform-module/terraform-aws-ecs-services)
[![](https://img.shields.io/github/languages/code-size/terraform-module/terraform-aws-ecs-services)](https://github.com/terraform-module/terraform-aws-ecs-services)
[![](https://img.shields.io/github/repo-size/terraform-module/terraform-aws-ecs-services)](https://github.com/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/github/languages/top/terraform-module/terraform-aws-ecs-services?color=green&logo=terraform&logoColor=blue)
![](https://img.shields.io/github/commit-activity/m/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/github/contributors/terraform-module/terraform-aws-ecs-services)
![](https://img.shields.io/github/last-commit/terraform-module/terraform-aws-ecs-services)
[![Maintenance](https://img.shields.io/badge/Maintenu%3F-oui-green.svg)](https://GitHub.com/terraform-module/terraform-aws-ecs-services/graphs/commit-activity)
[![GitHub forks](https://img.shields.io/github/forks/terraform-module/terraform-aws-ecs-services.svg?style=social&label=Fork)](https://github.com/terraform-module/terraform-aws-ecs-services)

---

## Usage example

IMPORTANT: The master branch is used in source just as an example. In your code, do not pin to master because there may be breaking changes between releases. Instead pin to the release tag (e.g. ?ref=tags/x.y.z) of one of our [latest releases](https://github.com/terraform-module/terraform-aws-ecs-services/releases).

See `examples` directory for working examples to reference:

```hcl
module "blueprint" {
  source  = "terraform-module/blueprint"
  version = "0.0.0"
}
```

## Assumptions

## Available features

- Create ECS tasks
- Create ECS services
- Memory based autoscaling
- CPU based autoscaling

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_variable"></a> [variable](#input\_variable) | defaul,description,type | `string` | `"variable"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_used"></a> [used](#output\_used) | used value |
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

Currently maintained by [Ivan Katliarchuk](https://github.com/ivankatliarchuk) and these [awesome contributors](https://github.com/terraform-module/terraform-aws-ecs-services/graphs/contributors).

[![ForTheBadge uses-git](http://ForTheBadge.com/images/badges/uses-git.svg)](https://GitHub.com/)

## Terraform Registry

- [Module](https://registry.terraform.io/modules/terraform-module/todo/aws)

## Resources

- [TFLint Rules](https://github.com/terraform-linters/tflint/tree/master/docs/rules)
- [Terraform modules](https://registry.terraform.io/namespaces/terraform-module)
- [Blog: ECS with Fargate and Terraform](https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/)
- [Tfm: example](https://github.com/finleap/tf-ecs-fargate-tmpl)
