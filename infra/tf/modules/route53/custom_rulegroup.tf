resource "aws_route53_resolver_firewall_rule_group" "custom" {
  name = "custom rulegroup"
}

resource "aws_route53_resolver_firewall_domain_list" "custom" {
  name = "custom"
  domains = [
    "twitter.com",
    "*.twitter.com",
  ]
}

resource "aws_route53_resolver_firewall_rule" "custom" {
  name                    = "custom"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = aws_route53_resolver_firewall_domain_list.custom.id
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.custom.id
  priority                = 1
}
