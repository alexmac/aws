module "packer_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "packer" {
  name               = "packer"
  assume_role_policy = module.packer_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_group" "packer_users" {
  name = "packer-users"
  path = "/"
}

resource "aws_iam_group_policy" "packer_assume" {
  name  = "packer-assume"
  group = aws_iam_group.packer_users.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = aws_iam_role.packer.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "SSM" {
  name = "SSM"
  role = aws_iam_role.packer.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ssm:PutParameter"
        Resource = "arn:aws:ssm:${var.region}:${var.account_id}:parameter/amis/*"
      },
      {
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:${var.region}::parameter/aws/service/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ami_creation" {
  name = "ami_creation"
  role = aws_iam_role.packer.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CopyImage",
          "ec2:CreateImage",
          "ec2:CreateKeyPair",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteKeyPair",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteSnapshot",
          "ec2:DeleteVolume",
          "ec2:DeregisterImage",
          "ec2:DescribeImageAttribute",
          "ec2:DescribeImages",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeRegions",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSnapshots",
          "ec2:DescribeSubnets",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:EnableImageDeprecation",
          "ec2:GetPasswordData",
          "ec2:ModifyImageAttribute",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifySnapshotAttribute",
          "ec2:RegisterImage",
          "ec2:RunInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances",
          "iam:GetInstanceProfile"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "this" {
  role_name = aws_iam_role.packer.name
  policy_names = [
    aws_iam_role_policy.SSM.name,
    aws_iam_role_policy.ami_creation.name,
  ]
}