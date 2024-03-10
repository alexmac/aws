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

locals {
  calambda_docker_image = "2100d454fc806c61189e1dd8feb2fe11a8dc7991"
}
