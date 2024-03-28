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

variable "ecs_execution_role_arn" {
  type = string
}

variable "ami_name" {
  type = string
}

variable "docker_command" {
  type = list(any)
}

variable "security_group_ids" {
  type = list(any)
}

variable "cluster_arn" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "packer_iam_role_arn" {
  type = string
}

locals {
  packer_docker_image = "9afa1e9bf2b6b87eac38d549c6a32361c09e6f19"
}
