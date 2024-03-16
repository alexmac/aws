resource "aws_security_group" "tailscale_sg" {
  name        = "tailscale-sg"
  description = "Traffic from tailscale"
  vpc_id      = var.vpc_id
  tags = {
    Name = "tailscale-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tailscale_ssh_access" {
  name        = "tailscale-ssh-access"
  description = "Allow SSH inbound traffic from tailscale"
  vpc_id      = var.vpc_id
  tags = {
    Name = "tailscale-ssh-access"
    used_by_packer_instance = "true"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.tailscale_sg.id]
  }
}
