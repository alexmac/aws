variable "account_id" {
  type = string
}


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

resource "aws_ebs_encryption_by_default" "strict" {
  enabled = true
}

resource "aws_ebs_snapshot_block_public_access" "strict" {
  state = "block-all-sharing"
}

resource "aws_ec2_image_block_public_access" "strict" {
  state = "block-new-sharing"
}

resource "aws_ec2_instance_metadata_defaults" "enforce-imdsv2" {
  http_tokens                 = "required"
  instance_metadata_tags      = "enabled"
  http_put_response_hop_limit = 2
}

resource "aws_accessanalyzer_analyzer" "external_access" {
  analyzer_name = "external-access-analyzer"
  type          = "ACCOUNT"
}

resource "aws_ecs_cluster" "default" {
  name = "default"

  tags = {
    Name = "default"
  }
}

module "securityhub" {
  source     = "./modules/security_hub"
  region     = data.aws_region.current.name
  account_id = var.account_id
}

module "route53" {
  source     = "./modules/route53"
  region     = data.aws_region.current.name
  account_id = var.account_id
}

module "kms_cloudtrailwatch" {
  source     = "./modules/kms/logs"
  region     = data.aws_region.current.name
  account_id = var.account_id
}

module "aws_support_role" {
  source     = "./modules/iams/aws_support_role"
  account_id = var.account_id
}

module "aws_admin_role" {
  source     = "./modules/iams/aws_admin_role"
  account_id = var.account_id
}

module "vpc-usw2-10-0" {
  source         = "./modules/vpc"
  account_id     = var.account_id
  region         = "us-west-2"
  class_b_prefix = "10.0"
  dns_rulegroup_ids = [
    module.route53.aws_rule_group_id,
    module.route53.custom_rule_group_id,
  ]
  vpc_name                = "usw2-10-0-0-0-16"
  kms_cloudtrailwatch_arn = module.kms_cloudtrailwatch.arn
}

module "ecs_execution_role" {
  source     = "./modules/iams/ecs_execution_role"
  account_id = var.account_id
}

module "tailscale-usw2-10-0" {
  source             = "./tailscale"
  account_id         = var.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id             = module.vpc-usw2-10-0.vpc_id
}

module "packer" {
  source                  = "./packer"
  account_id              = var.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  ecs_execution_role_arn  = module.ecs_execution_role.role_arn
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
  kms_cloudtrailwatch_arn = module.kms_cloudtrailwatch.arn
}

module "prod_cluster" {
  source                  = "./prod_cluster"
  account_id              = var.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  tailscale_ssh_access_sg = module.tailscale-usw2-10-0.tailscale_ssh_access_sg
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
}

module "processing_cluster" {
  source                  = "./processing_cluster"
  account_id              = var.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  tailscale_ssh_access_sg = module.tailscale-usw2-10-0.tailscale_ssh_access_sg
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
  kms_cloudtrailwatch_arn = module.kms_cloudtrailwatch.arn
}

module "gpu_cluster" {
  source                  = "./gpu"
  account_id              = var.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  tailscale_ssh_access_sg = module.tailscale-usw2-10-0.tailscale_ssh_access_sg
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
}

# module "eks_cluster" {
#   source                    = "./eks_cluster"
#   account_id                = var.account_id
#   private_subnet_ids        = module.vpc-usw2-10-0.private_subnet_ids
#   tailscale_ssh_access_sg   = module.tailscale-usw2-10-0.tailscale_ssh_access_sg
#   tailscale_https_access_sg = module.tailscale-usw2-10-0.tailscale_https_access_sg
#   vpc_id                    = module.vpc-usw2-10-0.vpc_id
#   kms_cloudtrailwatch_arn   = module.kms_cloudtrailwatch.arn
# }

module "github_actions" {
  source                  = "./github_actions"
  account_id              = var.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  tailscale_ssh_access_sg = module.tailscale-usw2-10-0.tailscale_ssh_access_sg
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
}

module "calambda" {
  source                  = "./calambda"
  account_id              = var.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id                  = module.vpc-usw2-10-0.vpc_id
  kms_cloudtrailwatch_arn = module.kms_cloudtrailwatch.arn
}

module "services-usw2-10-0" {
  source                    = "./services"
  account_id                = var.account_id
  region                    = data.aws_region.current.name
  public_subnet_ids         = module.vpc-usw2-10-0.public_subnet_ids
  vpc_id                    = module.vpc-usw2-10-0.vpc_id
  prod_alb_sg               = module.prod_cluster.prod_alb_sg
  prod_https_sg             = module.prod_cluster.prod_https_sg
  prod_internal_alb_sg      = module.prod_cluster.prod_internal_alb_sg
  tailscale_https_access_sg = module.tailscale-usw2-10-0.tailscale_https_access_sg
  packer_fargate_https_sg   = module.packer.packer_fargate_https_sg
  ecs_execution_role_arn    = module.ecs_execution_role.role_arn
  kms_cloudtrailwatch_arn   = module.kms_cloudtrailwatch.arn
}

module "cloudfront" {
  source     = "./cloudfront"
  account_id = var.account_id
}

module "alerting" {
  source     = "./alerting"
  account_id = var.account_id
  region     = data.aws_region.current.name
  kms_arn    = module.kms_cloudtrailwatch.arn
}

module "prometheus" {
  source     = "./modules/prometheus"
  account_id = var.account_id
  region     = data.aws_region.current.name
}

module "athena" {
  source     = "./modules/athena"
  region     = data.aws_region.current.name
  account_id = var.account_id
}
