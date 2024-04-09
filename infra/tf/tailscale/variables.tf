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

output "tailscale_ssh_access_sg" {
  value       = aws_security_group.tailscale_ssh_access.id
  description = "SG that allows tailscale SSH access"
}

output "tailscale_https_access_sg" {
  value       = aws_security_group.tailscale_https_access.id
  description = "SG that allows tailscale HTTPS access"
}
