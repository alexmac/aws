module "ec2_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ec2.amazonaws.com"]
}

resource "aws_iam_role" "server_ec2_role" {
  name               = "ephemeral-server"
  assume_role_policy = module.ec2_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "server_ec2_role" {
  role_name = aws_iam_role.server_ec2_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-sign"
  ]
}

resource "aws_iam_instance_profile" "server_ec2_instance_profile" {
  name = "ephemeral-server"
  path = "/"
  role = aws_iam_role.server_ec2_role.name
}
