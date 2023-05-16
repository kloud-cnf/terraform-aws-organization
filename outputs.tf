output "master_account_arn" {
  value = aws_organizations_organization.this.master_account_arn
}

output "master_account_email" {
  value = aws_organizations_organization.this.master_account_email
}

output "master_account_id" {
  value = aws_organizations_organization.this.master_account_id
}

output "org_accounts" {
  value = aws_organizations_organization.this.accounts
}

output "org_roots" {
  value = aws_organizations_organization.this.roots
}
