include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/kms/kms.hcl"
}

locals {

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
}

# Indicate the input values to use for the variables of the module.
inputs = {

  description = "Training Primary EKS KMS Key"
  key_usage   = "ENCRYPT_DECRYPT"
  aliases = ["eks-kms-key"]

}