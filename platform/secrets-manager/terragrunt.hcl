include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/secrets-manager/secret.hcl"
} 
locals {
  # Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
  project = local.env_vars.inputs.project

}

inputs = {
  secrets = {
    "/eks/${local.project}-secret" = {
      description = "${local.project} secret"
      secret_key_value = {
        project = "${local.project}"
      }
      recovery_window_in_days = 0 
    }
  }
}
