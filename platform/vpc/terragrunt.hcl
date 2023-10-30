include "root" {
    path = find_in_parent_folders()
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

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/vpc/vpc.hcl"
}

inputs = {

    cidr = "10.50.0.0/16"
    public_subnets = ["10.50.128.0/24","10.50.129.0/24"]
    private_subnets = [
    {
      name            = "eks-subnet-1"
      cidr_block      = "10.50.0.0/18"
      availability_zone = "${local.region}a"
    },
    {
      name            = "eks-subnet-2"
      cidr_block      = "10.50.64.0/18"
      availability_zone = "${local.region}b"
    }
    ]
    
    manage_default_security_group = true
    default_security_group_ingress = [
   {"description"      : "Outside to from VPC"
    "from_port"        : 0
    "to_port"          : 0
    "protocol"         : "-1"
    "cidr_blocks"      : "0.0.0.0/0"}
    ]

    default_security_group_egress = [
   {"description"      : "From inside VPC to Egress"
    "from_port"        : 0
    "to_port"          : 0
    "protocol"         : "-1"
    "cidr_blocks"      : "0.0.0.0/0"}
    ]


}