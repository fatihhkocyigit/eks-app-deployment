include "root" {
  path = find_in_parent_folders()
} 

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/eks/eks-addons.hcl"
}

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  project = local.environment_vars.inputs.project
  region = local.region_vars.inputs.region
  zone_name = local.environment_vars.inputs.zone_name
  argocd_ingress_host = "gitops.${local.zone_name}"
}

inputs = {
    loadbalancer_irsa_arn = "${dependency.eks-irsa.outputs.iam_role_arn}"
    vpc_id = "${dependency.eks-vpc.outputs.vpc_id}"
    cluster_region = "${local.region}"
    cluster_name = "${dependency.eks.outputs.cluster_name}"
    cluster_endpoint = "${dependency.eks.outputs.cluster_endpoint}"
    cluster_ca_cert= "${dependency.eks.outputs.cluster_certificate_authority_data}"
    image_repository = "602401143452.dkr.ecr.eu-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
    deploy_rancher = false
    deploy_aws_loadbalancer = true
    rancher_hostname = "rancher.${local.zone_name}"
    resful_alb_hostname = "*.${local.zone_name}"
    acm_certificate_arn = "${dependency.acm.outputs.acm_certificate_arn}"

    # Argocd Configurations
    argocd_ingress_host = local.argocd_ingress_host
    deploy_argocd = true
    argocd_iam_role_arn = "${dependency.eks-irsa.outputs.iam_role_arn}"
    loadbalancer_name = "${local.env}-loadbalancer"
    argocd_ssl_redirect_annotation = false
    # connects ingress endpoints for
    deploy_ingress_nginx_resource = true

    # External Secret
    deploy_external_secrets = true
    eso_iam_role_arn = "${dependency.eks-irsa-eso.outputs.iam_role_arn}"

}

dependency "eks" {
    config_path = "../cluster"
    mock_outputs = {
        cluster_name = "known after apply"
        eks_managed_node_groups_iam_role_arn = ""
        oidc_provider_arn = "known after apply"
    }
}

dependency "acm" {
    config_path = "../../acm"
    mock_outputs = {
        acm_certificate_arn = ""
    }
}

dependency "eks-irsa-eso" {
    config_path = "../irsa/eso"
    mock_outputs = {
        iam_role_arn = "known after apply"
    }
}

dependency "eks-irsa" {
    config_path = "../irsa/alb"
    mock_outputs = {
        iam_role_arn = "known after apply"
    }
}

dependency "eks-vpc" {
    config_path = "../../vpc"
    mock_outputs = {
        vpc_id = "known after apply"
    }
}