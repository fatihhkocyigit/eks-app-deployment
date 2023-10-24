include "root" {
  path = find_in_parent_folders()
} 

include "envcommon" {
  path = "${dirname(find_in_parent_folders())}/_envcommon/eks/eks.hcl"
}

locals {
  # Automatically load environment-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
}

inputs = {
  cluster_name = "training-eks" 
  cluster_version = "1.26"
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  cluster_encryption_config = [
    {
      provider_key_arn = "${dependency.kms.outputs.key_arn}"
      resources        = ["secrets"]
    }
  ]

  eks_managed_node_group_defaults = {
    disk_size      = 200
    instance_types = ["t3.xlarge"]
  }
  eks_managed_node_groups = {
    linux = {
      min_size     = 3
      max_size     = 3
      desired_size = 3

      instance_types = ["t3.xlarge"]
      capacity_type  = "ON_DEMAND"
    }
  }
  node_security_group_additional_rules = {
    "node_egress_22" = {
      description                   = "Egress SSH port for argocd"
      protocol                      = "tcp"
      from_port                     = 22
      to_port                       = 22
      type                          = "egress"
      cidr_blocks                   = ["0.0.0.0/0"]
    },
    "node_allow_egress_all" = {
      description                   = "Egress all"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "egress"
      cidr_blocks                   = ["0.0.0.0/0"]
    },
    "node_allow_ingress_vpc" = {
      description                   = "Ingress Inside VPC"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      cidr_blocks                   = [dependency.vpc.outputs.vpc_cidr_block]
    }
  }

  vpc_id     = "${dependency.vpc.outputs.vpc_id}"
  subnet_ids = dependency.vpc.outputs.private_subnets
  subnet_id_names = "*eks*"

}

dependency "kms" {
  config_path = "../kms"
  mock_outputs = {
    key_arn = ""
  }
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "known after apply"
    vpc_cidr_block = "0.0.0.0/0"
    private_subnets = ["10.50.0.0/18","10.50.64.0/18"]
  }
} 