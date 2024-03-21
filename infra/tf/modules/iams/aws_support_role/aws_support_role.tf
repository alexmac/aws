module "assume_role_policy" {
  source     = "../assume_role"
  account_id = var.account_id
  services   = []
}

resource "aws_iam_role" "aws_support_role" {
  name               = "aws-support-role"
  assume_role_policy = module.assume_role_policy.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSSupportAccess"
  ]
}
