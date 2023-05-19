locals {
  all_accounts = concat(var.accounts, var.lab_accounts)
  accounts     = { for account in local.all_accounts : account.account_name => account }

  # Support many-to-one service principals per single memeber account by building unique map
  # Result:
  # {
  #   "<account>/<service_principal>" = {
  #     principal = "<service_principal>"
  #     account  = "<account>"
  #     id       = "<account>/<service_principal>"
  #   }
  # }
  delegated_administator_accounts_service_principals = { for delegation in flatten([for account, config in local.accounts :
    [
      for v in try(config.delegated_service_principals, []) :
      {
        id                = format("%s/%s", account, v)
        account           = account,
        service_principal = v
      }
    ]
    ]) : delegation.id => delegation
  }
}

resource "aws_organizations_organization" "this" {
  aws_service_access_principals = var.organization.service_access_principals
  enabled_policy_types          = var.organization.enabled_policy_types
  feature_set                   = var.organization.feature_set
}

resource "aws_organizations_account" "account" {
  for_each = local.accounts

  name                       = each.value.account_name
  email                      = each.value.email
  parent_id                  = local.all_org_units[each.value.org_unit_path].id
  iam_user_access_to_billing = coalesce(each.value.iam_user_access_to_billing, lookup(local.ou_child_defaults[each.value.org_unit_path], "iam_user_access_to_billing", "DENY"))
  role_name                  = var.organization.cross_account_role_name
  close_on_deletion          = each.value.close_on_deletion
  create_govcloud            = try(each.value.create_govcloud, false)

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name, iam_user_access_to_billing]
  }
}

resource "aws_organizations_delegated_administrator" "delegated_administrators" {
  for_each = local.delegated_administator_accounts_service_principals

  account_id        = aws_organizations_account.account[each.value.account].id
  service_principal = each.value.service_principal
}
