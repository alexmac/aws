module "assume_role_policy" {
  source     = "../assume_role"
  account_id = var.account_id
  services   = []
}

resource "aws_iam_role" "admin" {
  name               = "admin"
  assume_role_policy = module.assume_role_policy.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "admin" {
  role_name = aws_iam_role.admin.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}