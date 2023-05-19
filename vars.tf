variable "organization" {
  type = object({
    service_access_principals = optional(list(string), [])
    enabled_policy_types      = optional(list(string), ["SERVICE_CONTROL_POLICY"])
    feature_set               = optional(string, "ALL")
    cross_account_role_name   = optional(string, "OrgAccessRole")
  })

  description = "Configuration for the organization's settings."
}

variable "organization_units" {
  type = list(object({
    path                   = string           # Must start with 'root', and be separated with '/'
    service_control_policy = optional(string) # Define SCP at OU level
    child_defaults = optional(object({
      iam_user_access_to_billing = optional(string, "DENY")
      service_control_policy     = optional(string) # Define SCP at account level
    }), {})
  }))

  validation {
    condition     = alltrue([for ou in var.organization_units : length(regexall("^root(\\/[\\w+]+)+$", ou.path)) == 1])
    error_message = "Organization unit names must start with 'root', and be separated with '/' for every level of nesting; eg. 'root/workloads/prod'."
  }

  description = "Configuration for the organization's units"
}

variable "accounts" {
  type = list(object({
    account_name                 = string
    email                        = string
    org_unit_path                = string
    iam_user_access_to_billing   = optional(string, "DENY")
    delegated_service_principals = optional(list(string), [])
    service_control_policy       = optional(string)
    close_on_deletion            = optional(bool, false)
    create_govcloud              = optional(bool, false)
  }))
  validation {
    condition = alltrue([
      for account in var.accounts : !(account.close_on_deletion && account.create_govcloud)
    ])
    error_message = "Cannot set close_on_deletion to true when create_govcloud is true."
  }

  description = "Configuration for the organization's accounts"
}

variable "lab_accounts" {
  type = list(object({
    account_name               = string
    email                      = string
    iam_user_access_to_billing = string
    org_unit_path              = optional(string, "root/labs")
    service_control_policy     = optional(string)
    close_on_deletion          = optional(bool, true)
  }))

  description = "Configuration for the organization's lab accounts"
}