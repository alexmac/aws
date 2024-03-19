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
  clean_old_amis_docker_image = "134c8a91cf6bb67d0540990df99ab3bc9e5c06f5"
}
