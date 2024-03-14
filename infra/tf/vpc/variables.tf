variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The VPC ID"
}

output "public_subnet_ids" {
  value = [
    module.pub-usw2-az1-172-31-0-0-22.subnet_id,
    module.pub-usw2-az2-172-31-4-0-22.subnet_id,
  ]
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value = [
    module.prv-usw2-az1-172-31-16-0-20.subnet_id,
    module.prv-usw2-az2-172-31-32-0-20.subnet_id,
  ]
  description = "The IDs of the private subnets"
}
