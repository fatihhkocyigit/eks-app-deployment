/* include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/ecr/ecr.hcl"
}

locals {

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
  project = local.env_vars.inputs.project
  account_id= local.account_vars.inputs.account_id

}

# Indicate the input values to use for the variables of the module.
inputs = {
  ecr_repo_names = ["${local.project}-private"]
  allowed_read_principals = ["arn:aws:iam::${local.account_id}:role/*"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

} */

