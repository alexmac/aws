resource "aws_security_group" "gpu_sg" {
  name        = "gpu-sg"
  description = "Traffic from gpu"
  vpc_id      = var.vpc_id
  tags = {
    Name = "gpu-sg"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "gpu_ollama_access" {
  name        = "tailscale-ollama-access"
  description = "Allow ollama inbound traffic from tailscale"
  vpc_id      = var.vpc_id
  tags = {
    Name                    = "tailscale-ollama-access"
    used_by_packer_instance = "true"
  }

  ingress {
    from_port       = 11434
    to_port         = 11434
    protocol        = "tcp"
    security_groups = [var.tailscale_ssh_access_sg]
  }
}