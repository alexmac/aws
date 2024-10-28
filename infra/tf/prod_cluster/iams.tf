module "ec2_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ec2.amazonaws.com"]
}

resource "aws_iam_role" "server_ec2_role" {
  name               = "server"
  assume_role_policy = module.ec2_assume_role.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-sign"
  ]
}

resource "aws_iam_instance_profile" "server_ec2_instance_profile" {
  name = "server"
  path = "/"
  role = aws_iam_role.server_ec2_role.name
}

resource "aws_iam_role_policy" "this" {
  name = "secret-access"
  role = aws_iam_role.server_ec2_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:tailscale/server-lJsNyf"
        ]
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "this" {
  role_name = aws_iam_role.server_ec2_role.name
  policy_names = [
    aws_iam_role_policy.this.name,
  ]
}
