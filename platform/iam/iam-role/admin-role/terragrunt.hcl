include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/iam/iam-assumable-role.hcl"
}

locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
  account_id = local.account_vars.inputs.account_id
  root_account_arn = "arn:aws:iam::${local.account_id}:root"
  project = local.environment_vars.inputs.project

}

# Indicate the input values to use for the variables of the module.
inputs = {
  trusted_role_arns = ["${local.root_account_arn}"]
  create_role = true
  role_name = "${local.project}-Admin"
  role_requires_mfa = false
  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
  number_of_custom_role_policy_arns = 1

}