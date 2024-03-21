variable "account_id" {
  type = string
}

variable "services" {
  type = list(any)
}

variable "source_arns" {
  type    = list(any)
  default = []
}

output "policy_document" {
  value = data.aws_iam_policy_document.policy.json
}
