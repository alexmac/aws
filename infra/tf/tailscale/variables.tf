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

output "tailscale_asg" {
  value = aws_autoscaling_group.tailscale_asg.arn
}

output "tailscale_asg_name" {
  value = aws_autoscaling_group.tailscale_asg.name
}
