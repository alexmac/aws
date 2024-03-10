terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40"
    }
  }

  required_version = ">= 1.7.0"

  backend "s3" {
    bucket         = "cafetech-terraform"
    key            = "default/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "cafetech-terraform"
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "vpc" {
  source = "./vpc"

  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  vpc_name   = "tf-main"
}

module "ecs_shared" {
  source = "./ecs_shared"
}

module "tailscale" {
  source             = "./tailscale"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}

module "packer" {
  source                 = "./packer"
  account_id             = data.aws_caller_identity.current.account_id
  region                 = data.aws_region.current.name
  private_subnet_ids     = module.vpc.private_subnet_ids
  ecs_execution_role_arn = module.ecs_shared.ecs_execution_role_arn
  vpc_id                 = module.vpc.vpc_id
}

module "prod_cluster" {
  source                  = "./prod_cluster"
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  private_subnet_ids      = module.vpc.private_subnet_ids
  tailscale_ssh_access_sg = module.tailscale.tailscale_ssh_access_sg
  vpc_id                  = module.vpc.vpc_id
}

module "instance_refresh" {
  source             = "./instance_refresh"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  prod_asg           = module.prod_cluster.prod_asg
  prod_cluster_arn   = module.prod_cluster.prod_cluster_arn
  tailscale_asg      = module.tailscale.tailscale_asg
}

module "calambda" {
  source             = "./calambda"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
}

module "services" {
  source                 = "./services"
  account_id             = data.aws_caller_identity.current.account_id
  region                 = data.aws_region.current.name
  public_subnet_ids      = module.vpc.public_subnet_ids
  vpc_id                 = module.vpc.vpc_id
  prod_alb_sg            = module.prod_cluster.prod_alb_sg
  ecs_execution_role_arn = module.ecs_shared.ecs_execution_role_arn
}


moved {
  from = module.services.aws_lb_listener.default_listener
  to   = module.services.aws_lb_listener.prod_alb
}
