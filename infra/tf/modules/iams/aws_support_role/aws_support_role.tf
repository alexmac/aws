module "assume_role_policy" {
  source     = "../assume_role"
  account_id = var.account_id
  services   = []
}

resource "aws_iam_role" "aws_support_role" {
  name               = "aws-support-role"
  assume_role_policy = module.assume_role_policy.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "aws_support_role" {
  role_name = aws_iam_role.aws_support_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSSupportAccess"
  ]
}