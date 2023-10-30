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
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
  project = local.env_vars.inputs.project

}

inputs = {
    role_name = "${local.project}_eks_service_role"
    assume_role_condition_test = "StringLike"
    role_policy_arns = {
      "secrets-manager" = "${dependency.secrets-manager-policy.outputs.arn}",
      "cluster-scaling" = "${dependency.scaling-policy.outputs.arn}",
      "kms"             = "${dependency.kms-policy.outputs.arn}",
      "ebs"             = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }

    oidc_providers = {
    main = {
      provider_arn               = dependency.eks-cluster.outputs.oidc_provider_arn
      namespace_service_accounts = ["defaul:eks-service-account"]
      }
    }
}

dependency "eks-cluster" {
    config_path = "../../../eks/cluster"
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