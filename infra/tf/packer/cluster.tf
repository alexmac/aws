resource "aws_ecs_cluster" "packer" {
  name = "packer"

  tags = {
    Name = "packer-ecs-cluster-${var.vpc_id}"
  }
}
