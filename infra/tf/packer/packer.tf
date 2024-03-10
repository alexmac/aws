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
  packer_docker_image = "0de5ae7d300fe9f18f93660ae00573ef031ce4eb"
}
