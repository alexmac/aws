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
  packer_docker_image = "8b120d0fede409703b3f2aae4bf2c472a79d7d3e"
}
