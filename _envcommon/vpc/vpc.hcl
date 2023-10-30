terraform {
  source = "git@github.com:kloia/platform-modules.git//aws-vpc"
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

# Indicate the input values to use for the variables of the module.
inputs = {

  name = "${local.project}-vpc"
  azs  = ["${local.region}a", "${local.region}b"]
  
  create_igw = true
  private_dedicated_network_acl = true
  create_private_subnet_route_table = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = true

}