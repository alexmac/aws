variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "public_subnet_ids" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "prod_alb_sg" {
  type = string
}

variable "prod_https_sg" {
  type = string
}

variable "prod_internal_alb_sg" {
  type = string
}

variable "tailscale_https_access_sg" {
  type = string
}

variable "packer_fargate_https_sg" {
  type = string
}

variable "ecs_execution_role_arn" {
  type = string
}