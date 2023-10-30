include "root" {
    path = find_in_parent_folders()
} 

include "envcommon" {
    path = "${dirname(find_in_parent_folders())}/_envcommon/iam/iam-policy.hcl"
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))  

  # Extract out common variables for reuse
  region = local.region_vars.inputs.region
  project = local.environment_vars.inputs.project

}

# Indicate the input values to use for the variables of the module.
inputs = {
    name        = "${local.project}-kms-policy"
    path        = "/"
    description = "kms policy for ${local.project} eks"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "kms:CreateGrant",
        "kms:ListGrants",
        "kms:RevokeGrant"
      ],
      "Resource": ["${dependency.kms.outputs.key_arn}"],
      "Condition": {
        "Bool": {
          "kms:GrantIsForAWSResource": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${dependency.kms.outputs.key_arn}"]
    }
  ]
}
EOF
}

dependency "kms" {
    config_path = "../../../kms"
    mock_outputs = {
        key_arn = ""
    }
}