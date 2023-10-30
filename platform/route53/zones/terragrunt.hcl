include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/route53/zone.hcl"
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))  
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl")) 

  secondary_region = local.region_vars.inputs.secondary_region
  region = local.region_vars.inputs.region
  project = local.env_vars.inputs.project
  zone_name = local.env_vars.inputs.zone_name

}

inputs = {
  zones = {
    "public.${local.zone_name}" = {
      "domain_name" = "${local.zone_name}",
      "create_cross_account" = true
    }
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  default_tags {
    tags = {
      Project = "${local.project}"
      Terraform = "true"
    }
  }
  region = "${local.region}"
}
provider "aws" {
  alias = "shared_infra"
  default_tags {
    tags = {
      Environment = "${local.project}"
      Terraform = "true"
    }
  }
  region = "${local.region}"
}
EOF
}