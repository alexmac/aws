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

variable "tailscale_ssh_access_sg" {
  type = string
}

output "gpu_asg" {
  value = aws_autoscaling_group.gpu_asg.arn
}

output "gpu_asg_name" {
  value = aws_autoscaling_group.gpu_asg.name
}
