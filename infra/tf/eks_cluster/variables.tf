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

variable "tailscale_https_access_sg" {
  type = string
}

variable "vpc_id" {
  type = string
}

# output "prod_alb_sg" {
#   value       = aws_security_group.prod_alb_sg.id
#   description = "SG to allow an ALB to reach containers on these hosts"
# }

# output "prod_sg" {
#   value       = aws_security_group.prod_sg.id
# }

# output "prod_asg_name" {
#   value = aws_autoscaling_group.prod_asg.name
# }

# output "prod_cluster_arn" {
#   value = aws_ecs_cluster.ecs_cluster.arn
# }