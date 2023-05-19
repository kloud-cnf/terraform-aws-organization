output "master_account_arn" {
  description = "The ARN (Amazon Resource Name) of the master account in the AWS Organizations organization."
  value       = aws_organizations_organization.this.master_account_arn
}

output "master_account_email" {
  description = "The email address associated with the master account in the AWS Organizations organization."
  value       = aws_organizations_organization.this.master_account_email
}

output "master_account_id" {
  description = "The unique identifier of the master account in the AWS Organizations organization."
  value       = aws_organizations_organization.this.master_account_id
}

output "org_accounts" {
  description = "The list of non-master accounts in the AWS Organizations organization."
  value       = aws_organizations_organization.this.non_master_accounts
}

output "org_roots" {
  description = "The list of root organizational units in the AWS Organizations organization."
  value       = aws_organizations_organization.this.roots
}

output "organizations_organization_id" {
  description = "The ID of the AWS Organizations organization."
  value       = aws_organizations_organization.this.id
}

output "organizations_account_ids" {
  description = "The list of account IDs created in AWS Organizations."
  value       = values(aws_organizations_account.account)[*].id
}

output "organizations_delegated_administrator_ids" {
  description = "The list of delegated administrator IDs in AWS Organizations."
  value       = values(aws_organizations_delegated_administrator.delegated_administrators)[*].id
}

output "organizations_service_control_policy_ids" {
  description = "The list of IDs for the AWS Organizations service control policies."
  value       = values(aws_organizations_policy.service_control_policies)[*].id
}

output "organizations_account_policy_attachment_ids" {
  description = "The list of policy attachment IDs for the AWS Organizations account service control policies."
  value       = values(aws_organizations_policy_attachment.account_service_control_policies)[*].id
}

output "organizations_ou_policy_attachment_ids" {
  description = "The list of policy attachment IDs for the AWS Organizations organizational unit service control policies."
  value       = values(aws_organizations_policy_attachment.org_units_service_control_policies)[*].id
}

output "root_organizational_unit_arn" {
  description = "The ARN of the root organizational unit."
  value       = aws_organizations_organization.this.roots[0].arn
}
