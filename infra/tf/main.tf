data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 32
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
}

module "securityhub" {
  source     = "./modules/security_hub"
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

module "kms_cloudtrailwatch" {
  source     = "./modules/kms/logs"
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

module "aws_support_role" {
  source     = "./modules/iams/aws_support_role"
  account_id = data.aws_caller_identity.current.account_id
}

module "vpc-usw2-10-0" {
  source         = "./modules/vpc"
  account_id     = data.aws_caller_identity.current.account_id
  region         = "us-west-2"
  class_b_prefix = "10.0"
  vpc_name       = "usw2-10-0-0-0-16"
}

module "ecs_shared" {
  source     = "./ecs_shared"
  account_id = data.aws_caller_identity.current.account_id
}

module "tailscale-usw2-10-0" {
  source             = "./tailscale"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id             = module.vpc-usw2-10-0.vpc_id
}

module "packer" {
  source                 = "./packer"
  account_id             = data.aws_caller_identity.current.account_id
  region                 = data.aws_region.current.name
  private_subnet_ids     = module.vpc-usw2-10-0.private_subnet_ids
  ecs_execution_role_arn = module.ecs_shared.ecs_execution_role_arn
  vpc_id                 = module.vpc-usw2-10-0.vpc_id
}

module "prod_cluster" {
  source                  = "./prod_cluster"
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  tailscale_ssh_access_sg = module.tailscale-usw2-10-0.tailscale_ssh_access_sg
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
}

module "instance_refresh" {
  source             = "./instance_refresh"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id             = module.vpc-usw2-10-0.vpc_id
  prod_asg_name      = module.prod_cluster.prod_asg_name
  prod_cluster_arn   = module.prod_cluster.prod_cluster_arn
  tailscale_asg      = module.tailscale-usw2-10-0.tailscale_asg
}

module "calambda" {
  source             = "./calambda"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id             = module.vpc-usw2-10-0.vpc_id
}

module "services-usw2-10-0" {
  source                 = "./services"
  account_id             = data.aws_caller_identity.current.account_id
  region                 = data.aws_region.current.name
  public_subnet_ids      = module.vpc-usw2-10-0.public_subnet_ids
  vpc_id                 = module.vpc-usw2-10-0.vpc_id
  prod_alb_sg            = module.prod_cluster.prod_alb_sg
  ecs_execution_role_arn = module.ecs_shared.ecs_execution_role_arn
}

module "cloudfront" {
  source     = "./cloudfront"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

module "alerting" {
  source     = "./alerting"
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  kms_arn    = module.kms_cloudtrailwatch.arn
}
