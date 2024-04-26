variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

variable "private_subnet_ids" {
  type = list(any)
}

variable "tailscale_ssh_access_sg" {
  type = string
}

variable "vpc_id" {
  type = string
}

output "processing_sg" {
  value = aws_security_group.processing_sg.id
}

output "processing_asg_name" {
  value = aws_autoscaling_group.processing_asg.name
}

output "processing_cluster_arn" {
  value = aws_ecs_cluster.ecs_cluster.arn
}