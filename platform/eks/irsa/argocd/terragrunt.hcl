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
  region = local.region_vars.inputs.region
  project = local.environment_vars.inputs.project

}

inputs = {
    role_name = "${local.project}-argocd"
    assume_role_condition_test = "StringLike"

    role_policy_arns = {
      "ecr" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
      "ssm" = "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
      "s3"  = "arn:aws:iam::aws:policy/AmazonS3FullAccess",
      "lambda" = "arn:aws:iam::aws:policy/AWSLambda_FullAccess",
      "events" = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"

    }

    oidc_providers = {
    main = {
      provider_arn               = dependency.eks-cluster.outputs.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-application-controller","argocd:argocd-server","argocd:argocd-repo-server"]
      }
    }
}

dependency "eks-cluster" {
    config_path = "../../cluster"
    mock_outputs = {
        oidc_provider_arn = "known after apply"
    }
}