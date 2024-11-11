module "server_ami" {
  source                  = "./ami"
  region                  = var.region
  account_id              = var.account_id
  ami_name                = "server"
  docker_command          = ["make", "server"]
  vpc_id                  = var.vpc_id
  cluster_arn             = aws_ecs_cluster.packer.arn
  cluster_name            = aws_ecs_cluster.packer.name
  private_subnet_ids      = var.private_subnet_ids
  ecs_execution_role_arn  = var.ecs_execution_role_arn
  packer_iam_role_arn     = aws_iam_role.packer.arn
  security_group_ids      = [aws_security_group.packer_fargate.id]
  kms_cloudtrailwatch_arn = var.kms_cloudtrailwatch_arn
}

module "tailscale_ami" {
  source                  = "./ami"
  region                  = var.region
  account_id              = var.account_id
  ami_name                = "tailscale"
  docker_command          = ["make", "tailscale"]
  vpc_id                  = var.vpc_id
  cluster_arn             = aws_ecs_cluster.packer.arn
  cluster_name            = aws_ecs_cluster.packer.name
  private_subnet_ids      = var.private_subnet_ids
  ecs_execution_role_arn  = var.ecs_execution_role_arn
  packer_iam_role_arn     = aws_iam_role.packer.arn
  security_group_ids      = [aws_security_group.packer_fargate.id]
  kms_cloudtrailwatch_arn = var.kms_cloudtrailwatch_arn
}

module "eks_ami" {
  source                  = "./ami"
  region                  = var.region
  account_id              = var.account_id
  ami_name                = "eks"
  docker_command          = ["make", "eks"]
  vpc_id                  = var.vpc_id
  cluster_arn             = aws_ecs_cluster.packer.arn
  cluster_name            = aws_ecs_cluster.packer.name
  private_subnet_ids      = var.private_subnet_ids
  ecs_execution_role_arn  = var.ecs_execution_role_arn
  packer_iam_role_arn     = aws_iam_role.packer.arn
  security_group_ids      = [aws_security_group.packer_fargate.id]
  kms_cloudtrailwatch_arn = var.kms_cloudtrailwatch_arn
}
