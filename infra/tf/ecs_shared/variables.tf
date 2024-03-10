variable "account_id" {
  type = string
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}