resource "aws_ecs_cluster" "packer" {
  name = "packer"
}

resource "aws_security_group" "packer" {
  name   = "packer"
  vpc_id = var.vpc_id
  tags = {
    Name = "packer"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  packer_docker_image = "b311a2f091ffc0bd8861b2402409e7d19befc5bd"
}
