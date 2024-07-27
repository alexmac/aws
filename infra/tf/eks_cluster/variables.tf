variable "account_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(any)
}

variable "tailscale_ssh_access_sg" {
  type = string
}

variable "tailscale_https_access_sg" {
  type = string
}

variable "vpc_id" {
  type = string
}
