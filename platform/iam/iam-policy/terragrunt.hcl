include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/iam/iam-policy.hcl"
}

locals {

  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
}

# Indicate the input values to use for the variables of the module.
inputs = {
    name        = "training-ecr"
    path        = "/"
    description = "training policy for ecr"
    policy = <<EOF
{
  "Statement": [
      {
          "Action": [
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetAuthorizationToken",
              "ecr:GetDownloadUrlForLayer",
              "ecr:GetRepositoryPolicy",
              "ecr:DescribeRepositories",
              "ecr:ListImages",
              "ecr:DescribeImages",
              "ecr:BatchGetImage"
          ],
          "Effect": "Allow",
          "Resource": "*"
      },
      {
          "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "ecr:BatchCheckLayerAvailability",
              "ecr:PutImage",
              "ecr:InitiateLayerUpload",
              "ecr:UploadLayerPart",
              "ecr:CompleteLayerUpload",
              "ecr:DescribeRepositories",
              "ecr:ListImages",
              "ecr:DescribeImages"
          ],
          "Effect": "Allow",
          "Resource": "*"
      }
  ],
  "Version": "2012-10-17"
}
EOF
}