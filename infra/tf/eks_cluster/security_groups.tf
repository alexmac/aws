resource "aws_security_group" "eks_control_plane" {
  name        = "eks-control-plane"
  description = "Traffic from eks"
  vpc_id      = var.vpc_id
  tags = {
    Name = "eks-control-plane"
  }
}

resource "aws_security_group" "eks_node_ingress" {
  name        = "eks-node"
  description = "Allows traffic from EKS control plane"
  vpc_id      = var.vpc_id
  tags = {
    Name = "eks-node"
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.eks_control_plane.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "eks_control_plane_ingress" {
  name        = "eks-control-plane-ingress"
  description = "Allows traffic from EKS nodes"
  vpc_id      = var.vpc_id
  tags = {
    Name = "eks-control-plane-ingress"
  }
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [
      aws_security_group.eks_node_ingress.id,
    ]
  }
}
