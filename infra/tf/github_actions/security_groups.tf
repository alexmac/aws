resource "aws_security_group" "github_sg" {
  name        = "github-sg"
  description = "Traffic from github"
  vpc_id      = var.vpc_id
  tags = {
    Name = "github-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "github_xray" {
  name        = "github-xray-ingress"
  description = "Allow host to send XRay traces to itself"
  vpc_id      = var.vpc_id
  tags = {
    Name = "github-xray-ingress"
  }

  ingress {
    from_port       = 40000
    to_port         = 40000
    protocol        = "udp"
    security_groups = [aws_security_group.github_sg.id]
  }
  ingress {
    from_port       = 40000
    to_port         = 40000
    protocol        = "tcp"
    security_groups = [aws_security_group.github_sg.id]
  }
}
