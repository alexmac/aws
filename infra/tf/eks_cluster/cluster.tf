locals {
  ami = "ami-088e753de03872a41"
}

resource "aws_launch_template" "eks_node_launch_template" {
  name_prefix            = "lt-eks-node-${var.vpc_id}-"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 20
      volume_type           = "gp3"
    }
  }

  ebs_optimized = true

  image_id = local.ami

  instance_type = "t4g.small"

  monitoring {
    enabled = false
  }

  network_interfaces {
    security_groups = [
      aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id,
      aws_security_group.eks_node_ingress.id,
      var.tailscale_ssh_access_sg,
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "eks-node"
    }
  }

  user_data = base64encode(<<EOT
---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${aws_eks_cluster.cluster.name}
    apiServerEndpoint: ${aws_eks_cluster.cluster.endpoint}
    certificateAuthority: ${aws_eks_cluster.cluster.certificate_authority[0].data}
    cidr: "10.1.0.0/22"
  kubelet:
    config:
      maxPods: 17
      clusterDNS:
      - 10.1.0.10
    flags:
    - "--node-labels=eks.amazonaws.com/nodegroup-image=${local.ami},eks.amazonaws.com/capacityType=SPOT,eks.amazonaws.com/nodegroup=${aws_eks_cluster.cluster.name}-nodes"

EOT
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = false
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "resource-name"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/eks/prod-eks/cluster"
  retention_in_days = 7
  kms_key_id        = var.kms_cloudtrailwatch_arn
}

resource "aws_eks_cluster" "cluster" {
  name     = "prod-eks"
  role_arn = aws_iam_role.eks_cluster_role.arn

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  depends_on = [aws_cloudwatch_log_group.this]

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids = [
      # aws_security_group.eks_control_plane.id,
      # aws_security_group.eks_control_plane_ingress.id,
      var.tailscale_https_access_sg,
    ]
  }
  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = "10.1.0.0/22"
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "prod-eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_ec2_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 0
    max_size     = 2
    min_size     = 0
  }

  update_config {
    max_unavailable_percentage = 100
  }

  capacity_type = "SPOT"

  ami_type = "CUSTOM"
  launch_template {
    id      = aws_launch_template.eks_node_launch_template.id
    version = aws_launch_template.eks_node_launch_template.latest_version
  }

  # ami_type = "AL2023_ARM_64_STANDARD"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.6"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_identity_provider_config" "cluster" {
  cluster_name = aws_eks_cluster.cluster.name

  oidc {
    client_id                     = "sts.amazonaws.com"
    identity_provider_config_name = "example"
    issuer_url                    = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  }
}

resource "aws_eks_pod_identity_association" "cafetech-service-account" {
  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = "default"
  service_account = "cafetech-service-account"
  role_arn        = "arn:aws:iam::${var.account_id}:role/service-cafetech"
}

resource "aws_iam_openid_connect_provider" "cluster_oidc" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # From 09/01/2009 to 06/28/2034
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.17.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "eks-pod-identity-agent" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "eks-pod-identity-agent"
  addon_version               = "v1.2.0-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_access_entry" "example" {
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = "arn:aws:iam::${var.account_id}:user/alexblog"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "AmazonEKSAdminPolicy" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
  principal_arn = "arn:aws:iam::${var.account_id}:user/alexblog"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "AmazonEKSClusterAdminPolicy" {
  cluster_name  = aws_eks_cluster.cluster.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${var.account_id}:user/alexblog"

  access_scope {
    type = "cluster"
  }
}