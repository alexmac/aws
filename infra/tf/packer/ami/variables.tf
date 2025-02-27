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

variable "kms_cloudtrailwatch_arn" {
  type        = string
  description = "KMS key ARN for CloudWatch log encryption"
}

locals {
  packer_docker_image = "a81536e4eceae241cfdeb80a79e68f6f0c7a4fcb"
}
