include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/iam/iam-irsa.hcl"
}

locals {
# Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
}

inputs = {
    role_name = "eks_service_role"
    role_policy_arns = {
      #"ssm" = "${dependency.ssm-policy.outputs.arn}",
      "secrets-manager" = "${dependency.secrets-manager-policy.outputs.arn}",
      "kms" ="${dependency.kms-policy.outputs.arn}",
    }
}

dependency "eks-cluster" {
    config_path = "../../../eks"
    mock_outputs = {
        oidc_provider_arn = "known after apply"
    }
}


dependency "secrets-manager-policy" {
    config_path = "../../iam-policy/secrets-manager-policy"
    mock_outputs = {
        arn = "known after apply"
    }
}

/* dependency "ssm-policy" {
    config_path = "../../iam-policy/ssm"
    mock_outputs = {
        arn = "known after apply"
    }
}
 */
dependency "kms-policy" {
    config_path = "../../iam-policy/eks-kms-policy"
    mock_outputs = {
        arn = "known after apply"
    }
}

dependency "scaling-policy" {
    config_path = "../../iam-policy/cluster-scaling-policy"
    mock_outputs = {
        arn = "known after apply"
    }
}