module "tailscale_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ec2.amazonaws.com"]
}

resource "aws_iam_role" "tailscale_ec2_role" {
  name               = "tailscale-tf"
  assume_role_policy = module.tailscale_assume_role.policy_document
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-sign"
  ]

  inline_policy {
    name = "secret-access"
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
}

resource "aws_iam_instance_profile" "tailscale_ec2_instance_profile" {
  name = "tailscale-tf2"
  path = "/"
  role = aws_iam_role.tailscale_ec2_role.name
}
