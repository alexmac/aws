data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

data "aws_iam_policy_document" "tailscale_secret_access" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:tailscale-IglZn3"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role" "tailscale_ec2_role" {
  name               = "tailscale-tf"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-sign"
  ]

  inline_policy {
    name   = "secret-access"
    policy = data.aws_iam_policy_document.tailscale_secret_access.json
  }
}

resource "aws_iam_instance_profile" "tailscale_ec2_instance_profile" {
  name = "tailscale-tf2"
  path = "/"
  role = aws_iam_role.tailscale_ec2_role.name
}
