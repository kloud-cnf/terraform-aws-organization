locals {
  # Create a map that represents the OUs and their hierarchical structure.
  # Iterates over the levels of nested OU provided via `var.organization_units` list.
  # For each OU at a specific level, a map is created with attributes such as `name`, `parent_name`...
  # The map is nested within the corresponding level key in the `org_units_levels_all` map.
  # OUs are filtered based on their path length to ensure they are at the correct level.
  # The resulting `org_units_levels_all` map provides a structured representation of the OUs for further processing in the module.
  # Result:
  # {
  #   "1" = {
  #     "root/labs" = {...}
  #     "root/workloads" = {...}
  #   }
  #   "2" = {
  #     "root/workloads/SDLC" = {...}
  #   }
  #   "3" = {}
  #   "4" = {}
  #   "5" = {}
  # }
  org_units_levels_all = { for level in range(1, 6) : level => { for ou in var.organization_units : ou.path => {
    name                   = split("/", ou.path)[level]                                     # Turns `"root/workloads/dev"` into `"dev"`
    parent_name            = trimsuffix(ou.path, format("/%s", split("/", ou.path)[level])) # Turns `"root/workloads/dev"` into `"root/workloads"`
    hierarchy              = split("/", ou.path)                                            # Turns `"root/workloads/dev"` into `["root", "workloads", "dev"]`
    child_defaults         = { for k, v in ou.child_defaults : k => v if v != null }        # Removes any key-value pairs where the value is null
    service_control_policy = ou.service_control_policy
    } if length(split("/", ou.path)) == level + 1 }
  }


  # The `org_units_flat` local variable combines the default-attached SCP with the organizational units (OUs) from the `org_units_levels_all` local map.
  # Merges the default-attached SCP for the root with the values of the `org_units_levels_all` map.
  # The `values(local.org_units_levels_all)...` expression retrieves all the OU maps from `org_units_levels_all` and spreads them as arguments to the `merge` function.
  # This ensures that the resulting `org_units_flat` map includes both the default-attached SCP and the OUs at different levels.
  # Result:
  # {
  #   "root" = {}
  #   "root/workloads" = {...}
  #   "root/workloads/prod" = {...}
  # }
  org_units_flat = merge(
    { root = { child_defaults = {}, service_control_policy = null } },
    values(local.org_units_levels_all)...
  )

  # Calculate defaults for child accounts in an OU based on all parent OU (child OU settings take precedence)
  # ...
  # The `ou_child_defaults` local variable constructs a map representing the child defaults for each organizational unit (OU) in the `local.org_units_flat` map.
  # Iterate over `local.org_units_flat`. the key represents the OU name and the value is the OU map.
  # For each OU, a list comprehension is used to iterate over the levels of its hierarchy.
  # Within each level, retrieve the child defaults from the corresponding parent OU in the `local.org_units_flat` map.
  # The parent OU is accessed by joining the hierarchy path segments up to the current level, and then looking up the child defaults for that parent OU.
  # The resulting child defaults for each OU are merged into a map using `merge([...])` to combine the child defaults from all levels.
  # The final `ou_child_defaults` map includes the child defaults for each OU in `local.org_units_flat`.
  # Result:
  # {
  #   "root" = {}
  #   "root/labs" = {
  #     "iam_user_access_to_billing" = "DENY"
  #   }
  #   "root/workloads" = {
  #     "iam_user_access_to_billing" = "ALLOW"
  #   }
  #   "root/workloads/SDLC" = {
  #     "iam_user_access_to_billing" = "ALLOW"
  #   }
  # }
  ou_child_defaults = { for key, ou in local.org_units_flat : key => merge([
    for level in range(length(lookup(ou, "hierarchy", []))) : lookup(local.org_units_flat[join("/", slice(ou.hierarchy, 0, level + 1))], "child_defaults", {})
  ]...) }

  # Details of all org unit resources
  # ...
  # The `all_org_units` local combines the OUs from different levels into a single map.
  # It merges the root OU, which is accessed from `aws_organizations_organization.this.roots[0]`, with OUs from each level.
  # The `aws_organizations_organizational_unit.level_X` represents the OUs at each specific level, where X ranges from 1 to 5.
  # The resulting `all_org_units` map includes the OUs from different levels, providing a consolidated representation of all OUs in the organization.
  # Note that currently AWS Organizations supports up to 5 levels of OUs from the organization root.
  # Result:
  # {
  #   "root/workloads" = (object)aws_organizations_organizational_unit.level_1.["root/workloads"]
  #   "root/workloads/dev" = (object)aws_organizations_organizational_unit.level_2.["root/workloads/dev"]
  # }
  all_org_units = merge(
    { root = aws_organizations_organization.this.roots[0] },
    aws_organizations_organizational_unit.level_1,
    aws_organizations_organizational_unit.level_2,
    aws_organizations_organizational_unit.level_3,
    aws_organizations_organizational_unit.level_4,
    aws_organizations_organizational_unit.level_5, # AWS Organizations currently supports 5 levels of OUs from org root
  )
}

resource "aws_organizations_organizational_unit" "level_1" {
  for_each = local.org_units_levels_all[1]

  name      = each.value.name
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "level_2" {
  for_each = local.org_units_levels_all[2]

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_1[each.value.parent_name].id
}

resource "aws_organizations_organizational_unit" "level_3" {
  for_each = local.org_units_levels_all[3]

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_2[each.value.parent_name].id
}

resource "aws_organizations_organizational_unit" "level_4" {
  for_each = local.org_units_levels_all[4]

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_3[each.value.parent_name].id
}

resource "aws_organizations_organizational_unit" "level_5" {
  for_each = local.org_units_levels_all[5]

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.level_4[each.value.parent_name].id
}