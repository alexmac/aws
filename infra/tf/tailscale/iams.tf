module "tailscale_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ec2.amazonaws.com"]
}

resource "aws_iam_role" "tailscale_ec2_role" {
  name               = "tailscale-${var.vpc_id}"
  assume_role_policy = module.tailscale_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "tailscale_ec2_role" {
  role_name = aws_iam_role.tailscale_ec2_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-signing"
  ]
}

resource "aws_iam_role_policy" "tailscale_ec2_role_secrets_policy" {
  name = "tailscale-${var.vpc_id}-secrets"
  role = aws_iam_role.tailscale_ec2_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:tailscale-IglZn3"
        ]
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "tailscale_ec2_role_inline_policies" {
  role_name = aws_iam_role.tailscale_ec2_role.name
  policy_names = [
    aws_iam_role_policy.tailscale_ec2_role_secrets_policy.name
  ]
}


resource "aws_iam_instance_profile" "tailscale_ec2_instance_profile" {
  name = "tailscale-${var.vpc_id}"
  path = "/"
  role = aws_iam_role.tailscale_ec2_role.name
}
