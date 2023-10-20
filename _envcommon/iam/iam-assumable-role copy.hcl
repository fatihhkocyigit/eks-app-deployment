terraform {
  source = "git@github.com:kloia/platform-modules.git//aws-iam/modules/iam-assumable-role"
}

locals {
  # Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
}

# Indicate the input values to use for the variables of the module.
inputs = {

}