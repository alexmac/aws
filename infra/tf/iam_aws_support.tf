module "support_assume_role" {
  source     = "./modules/iams/assume_role"
  account_id = var.account_id
  services   = []
}

resource "aws_iam_role" "support_role" {
  name               = "aws-support"
  assume_role_policy = module.support_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "support_role" {
  role_name = aws_iam_role.support_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSSupportAccess"
  ]
}