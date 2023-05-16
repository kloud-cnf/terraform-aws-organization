variable "organization" {
  type = object({
    service_access_principals = list(string)
    enabled_policy_types      = list(string)
    feature_set               = string
  })
  default = {
    service_access_principals = []
    enabled_policy_types      = ["SERVICE_CONTROL_POLICY"]
    feature_set               = "ALL"
  }
}


variable "accounts" {
  type = list(object({
    account_name               = string
    email                      = string
    iam_user_access_to_billing = string
    org_unit                   = string
  }))
}
