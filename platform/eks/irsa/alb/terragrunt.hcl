include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/eks/eks-irsa.hcl"
}

locals {
# Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  


  # Extract out common variables for reuse
  project = local.environment_vars.inputs.project
  region = local.region_vars.inputs.region
}

inputs = {
    role_name = "${local.project}-eks-lb"
    attach_load_balancer_controller_policy = true

    oidc_providers = {
    main = {
      provider_arn               = dependency.eks-cluster.outputs.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
      }
    }
}

dependency "eks-cluster" {
    config_path = "../../cluster"
    mock_outputs = {
        oidc_provider_arn = "known after apply"
    }
}