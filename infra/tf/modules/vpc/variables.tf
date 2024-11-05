variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "class_b_prefix" {
  type = string
}

variable "dns_rulegroup_ids" {
  type = list(string)
}

output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The VPC ID"
}

output "public_subnet_ids" {
  value = [
    # module.pub-az1-subnet-1.subnet_id,
    module.pub-az2-subnet-1.subnet_id,
    module.pub-az3-subnet-1.subnet_id,
  ]
  description = "The IDs of the public subnets"
}

output "private_subnet_ids" {
  value = [
    module.prv-az1-subnet-1.subnet_id,
    module.prv-az2-subnet-1.subnet_id,
  ]
  description = "The IDs of the private subnets"
}
