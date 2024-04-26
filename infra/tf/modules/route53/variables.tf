variable "account_id" {
  type = string
}

variable "region" {
  type = string
}

output "aws_rule_group_id" {
  value = aws_route53_resolver_firewall_rule_group.aws.id
}

output "custom_rule_group_id" {
  value = aws_route53_resolver_firewall_rule_group.custom.id
}
