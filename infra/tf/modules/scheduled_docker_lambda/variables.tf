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

variable "lambda_role_arn" {
  type = string
}

variable "schedule_name" {
  type = string
}

variable "schedules" {
  type = map(any)
}

variable "timeout" {
  type    = number
  default = 60
}

variable "docker_image" {
  type = string
}
