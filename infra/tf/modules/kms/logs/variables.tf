variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

output "arn" {
  value = aws_kms_key.this.arn
}

output "alias" {
  value = aws_kms_alias.this.name
}
