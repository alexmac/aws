module "ec2_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ec2.amazonaws.com"]
}

resource "aws_iam_role" "eks_node_ec2_role" {
  name               = "eks-node"
  assume_role_policy = module.ec2_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "inline_policies" {
  role_name = aws_iam_role.eks_node_ec2_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy",
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
    "arn:aws:iam::${var.account_id}:policy/ssh-host-key-sign"
  ]
}

resource "aws_iam_instance_profile" "eks_node_ec2_role" {
  name = "eks-node"
  path = "/"
  role = aws_iam_role.eks_node_ec2_role.name
}


# Note: as of 03/27/2024 you can't add an aws:SourceAccount conditional to this...
data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = "eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.policy.json
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "eks_cluster_role_managed_policies" {
  role_name = aws_iam_role.eks_cluster_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  ]
}