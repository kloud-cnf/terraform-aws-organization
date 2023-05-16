locals {
  organization_units = toset([for account in var.accounts : account.org_unit if account.org_unit != ""])

  organization_accounts = { for account in var.accounts : account.account_name => {
    account_name               = account.account_name
    email                      = account.email
    iam_user_access_to_billing = account.iam_user_access_to_billing
    org_unit                   = account.org_unit == "" ? aws_organizations_organization.this.roots[0].id : aws_organizations_organizational_unit.this[account.org_unit].id
    }
  }
}