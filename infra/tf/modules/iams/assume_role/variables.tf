variable "account_id" {
  type = string
}

variable "services" {
  type = list(any)
}

output "policy_document" {
  value = data.aws_iam_policy_document.policy.json
}
