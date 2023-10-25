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

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region

}

inputs = {
  secrets = {
    "/eks/training" = {
      description = "training secret"
      secret_key_value = {
        project = "training"
      }
      recovery_window_in_days = 0 
    }
  }
}
