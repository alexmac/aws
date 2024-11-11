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

variable "lambda_role_arn" {
  type = string
}

variable "lambda_name" {
  type = string
}

variable "docker_image" {
  type = string
}

variable "timeout" {
  type    = number
  default = 60
}

variable "kms_cloudtrailwatch_arn" {
  type        = string
  description = "KMS key ARN for CloudWatch log encryption"
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = null
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
