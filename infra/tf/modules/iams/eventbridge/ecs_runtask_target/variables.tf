variable "account_id" {
  type = string
}

variable "name" {
  type = string
}

variable "ecs_cluster_arn" {
  type = string
}

output "arn" {
  value = aws_iam_role.eventbridge_scheduler.arn
}
