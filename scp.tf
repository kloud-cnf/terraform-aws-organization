locals {
  # Get all accounts with a direct SCP attachment
  scp_attachments_accounts = { for k, v in {
    for key, account in local.accounts : key =>
    account.service_control_policy != null ? account.service_control_policy : lookup(local.org_units_flat[account.org_unit_path].child_defaults, "service_control_policy", null)
  } : k => v if v != null && v != "" }

  # Get all OUs with a direct SCP attachment
  scp_attachments_ou = { for k, v in {
    for key, ou in local.org_units_flat : key =>
    ou.service_control_policy != null ? ou.service_control_policy : lookup(try(local.org_units_flat[ou.parent_name].child_defaults, {}), "service_control_policy", null)
  } : k => v if v != null && v != "" }
}

# Service Control Policies
resource "aws_organizations_policy" "service_control_policies" {
  for_each = toset([
    for filename in fileset("${path.module}/templates/service-control-policies", "*.json.tpl") : replace(filename, ".json.tpl", "")
  ])

  name    = trimsuffix(each.value, ".json.tpl")
  content = templatefile("${path.module}/templates/service-control-policies/${each.value}.json.tpl", {})
}

# Account attachments
resource "aws_organizations_policy_attachment" "account_service_control_policies" {
  for_each = local.scp_attachments_accounts

  policy_id = aws_organizations_policy.service_control_policies[each.value].id
  target_id = aws_organizations_account.account[each.key].id
}

# OU attachments
resource "aws_organizations_policy_attachment" "org_units_service_control_policies" {
  for_each = local.scp_attachments_ou

  policy_id = aws_organizations_policy.service_control_policies[each.value].id
  target_id = aws_organizations_organizational_unit.level_1[each.key].id
}
