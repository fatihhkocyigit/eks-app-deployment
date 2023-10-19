locals {

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  region   = local.region_vars.inputs.region
  s3_bucket_name = local.account_vars.inputs.s3_bucket_name
}

generate "provider" {
  path = "provider.tf"
  if_exists = "skip"
  contents = <<EOF
provider "aws" {
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
  region = "${local.region}"
}
EOF
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "${local.s3_bucket_name}"
    key            = "platform/${path_relative_to_include()}/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
EOF
}

inputs = merge(
  local.account_vars.inputs,
  local.region_vars.inputs,
)