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

variable "kms_cloudtrailwatch_arn" {
  type        = string
  description = "KMS key ARN for CloudWatch log encryption"
}

locals {
  calambda_docker_image = "a5889a5236a2a57feccf5a96ea4553aa3184be49"
}
