variable "account_id" {
  type = string
}

output "role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}