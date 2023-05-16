resource "aws_organizations_organization" "this" {
  aws_service_access_principals = var.organization.service_access_principals
  enabled_policy_types          = var.organization.enabled_policy_types
  feature_set                   = var.organization.feature_set
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = local.organization_units

  name      = each.value
  parent_id = aws_organizations_organization.this.id
}

resource "aws_organizations_account" "account" {
  for_each = local.organization_accounts

  name                       = each.value.account_name
  email                      = each.value.email
  parent_id                  = each.value.org_unit
  iam_user_access_to_billing = each.value.iam_user_access_to_billing
  role_name                  = "OrgAccessRole"

  # There is no AWS Organizations API for reading role_name
  lifecycle {
    ignore_changes = [role_name, iam_user_access_to_billing]
  }
}