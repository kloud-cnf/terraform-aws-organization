# terraform-aws-organization

> Terraform module to manage an AWS Organization

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Contents

- [SCP Support](#scp-support)
- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

---

## SCP Support
[Example policies](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps_examples.html) can be added as under [templates](./templates/service-control-policies/)

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_organizations_account.account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) | resource |
| [aws_organizations_delegated_administrator.delegated_administrators](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator) | resource |
| [aws_organizations_organization.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization) | resource |
| [aws_organizations_organizational_unit.level_1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_organizational_unit.level_5](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organizational_unit) | resource |
| [aws_organizations_policy.service_control_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.account_service_control_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |
| [aws_organizations_policy_attachment.org_units_service_control_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accounts"></a> [accounts](#input\_accounts) | Configuration for the organization's accounts | <pre>list(object({<br>    account_name                 = string<br>    email                        = string<br>    org_unit_path                = string<br>    iam_user_access_to_billing   = optional(string, "DENY")<br>    delegated_service_principals = optional(list(string), [])<br>    service_control_policy       = optional(string)<br>    close_on_deletion            = optional(bool, false)<br>    create_govcloud              = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_lab_accounts"></a> [lab\_accounts](#input\_lab\_accounts) | Configuration for the organization's lab accounts | <pre>list(object({<br>    account_name               = string<br>    email                      = string<br>    iam_user_access_to_billing = string<br>    org_unit_path              = optional(string, "root/labs")<br>    service_control_policy     = optional(string)<br>    close_on_deletion          = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_organization"></a> [organization](#input\_organization) | Configuration for the organization's settings. | <pre>object({<br>    service_access_principals = optional(list(string), [])<br>    enabled_policy_types      = optional(list(string), ["SERVICE_CONTROL_POLICY"])<br>    feature_set               = optional(string, "ALL")<br>    cross_account_role_name   = optional(string, "OrgAccessRole")<br>  })</pre> | n/a | yes |
| <a name="input_organization_units"></a> [organization\_units](#input\_organization\_units) | Configuration for the organization's units | <pre>list(object({<br>    path                   = string           # Must start with 'root', and be separated with '/'<br>    service_control_policy = optional(string) # Define SCP at OU level<br>    child_defaults = optional(object({<br>      iam_user_access_to_billing = optional(string, "DENY")<br>      service_control_policy     = optional(string) # Define SCP at account level<br>    }), {})<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_master_account_arn"></a> [master\_account\_arn](#output\_master\_account\_arn) | The ARN (Amazon Resource Name) of the master account in the AWS Organizations organization. |
| <a name="output_master_account_email"></a> [master\_account\_email](#output\_master\_account\_email) | The email address associated with the master account in the AWS Organizations organization. |
| <a name="output_master_account_id"></a> [master\_account\_id](#output\_master\_account\_id) | The unique identifier of the master account in the AWS Organizations organization. |
| <a name="output_org_accounts"></a> [org\_accounts](#output\_org\_accounts) | The list of non-master accounts in the AWS Organizations organization. |
| <a name="output_org_roots"></a> [org\_roots](#output\_org\_roots) | The list of root organizational units in the AWS Organizations organization. |
| <a name="output_organizations_account_ids"></a> [organizations\_account\_ids](#output\_organizations\_account\_ids) | The list of account IDs created in AWS Organizations. |
| <a name="output_organizations_account_policy_attachment_ids"></a> [organizations\_account\_policy\_attachment\_ids](#output\_organizations\_account\_policy\_attachment\_ids) | The list of policy attachment IDs for the AWS Organizations account service control policies. |
| <a name="output_organizations_delegated_administrator_ids"></a> [organizations\_delegated\_administrator\_ids](#output\_organizations\_delegated\_administrator\_ids) | The list of delegated administrator IDs in AWS Organizations. |
| <a name="output_organizations_organization_id"></a> [organizations\_organization\_id](#output\_organizations\_organization\_id) | The ID of the AWS Organizations organization. |
| <a name="output_organizations_ou_policy_attachment_ids"></a> [organizations\_ou\_policy\_attachment\_ids](#output\_organizations\_ou\_policy\_attachment\_ids) | The list of policy attachment IDs for the AWS Organizations organizational unit service control policies. |
| <a name="output_organizations_service_control_policy_ids"></a> [organizations\_service\_control\_policy\_ids](#output\_organizations\_service\_control\_policy\_ids) | The list of IDs for the AWS Organizations service control policies. |
| <a name="output_root_organizational_unit_arn"></a> [root\_organizational\_unit\_arn](#output\_root\_organizational\_unit\_arn) | The ARN of the root organizational unit. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
