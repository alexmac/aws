data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "server_ec2_role" {
  name               = "server"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-sign"
  ]
}

resource "aws_iam_instance_profile" "server_ec2_instance_profile" {
  name = "server"
  path = "/"
  role = aws_iam_role.server_ec2_role.name
}

