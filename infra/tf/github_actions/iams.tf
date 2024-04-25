module "github_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ec2.amazonaws.com"]
}

resource "aws_iam_role" "github_ec2_role" {
  name               = "github-${var.vpc_id}"
  assume_role_policy = module.github_assume_role.policy_document
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
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
            "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:github/runner/*"
          ]
          Effect = "Allow"
        },
      ]
    })
  }
}

resource "aws_iam_instance_profile" "github_ec2_instance_profile" {
  name = "github-${var.vpc_id}"
  path = "/"
  role = aws_iam_role.github_ec2_role.name
}
