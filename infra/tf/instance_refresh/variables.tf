variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "private_subnet_ids" {
  type = list(any)
}

variable "vpc_id" {
  type = string
}

variable "prod_asg_name" {
  type = string
}

variable "prod_cluster_arn" {
  type = string
}

variable "tailscale_asg" {
  type = string
}

locals {
  instance_refresh_docker_image = "411b065f69a085cbe1c163eba52e7010d4e7bc26"
}
