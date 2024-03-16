resource "aws_security_group" "packer_fargate" {
  name        = "packer-fargate"
  description = "Traffic from packer fargate"
  vpc_id      = var.vpc_id
  tags = {
    Name = "packer-fargate"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "packer_instance" {
  name        = "packer-instance"
  description = "Traffic from packer instance"
  vpc_id      = var.vpc_id
  tags = {
    Name = "packer-instance"
    used_by_packer_instance = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "packer_fargate_ssh" {
  name        = "packer-fargate-ssh"
  description = "Allow SSH inbound traffic from packer fargate"
  vpc_id      = var.vpc_id
  tags = {
    Name = "packer-fargate-ssh"
    used_by_packer_instance = "true"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    security_groups = [
      aws_security_group.packer_fargate.id
    ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
