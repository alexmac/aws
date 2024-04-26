resource "aws_route53_resolver_firewall_rule_group" "aws" {
  name = "aws provided"
}

resource "aws_route53_resolver_firewall_rule" "AWSManagedDomainsAggregateThreatList" {
  name                    = "AWSManagedDomainsAggregateThreatList"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = "rslvr-fdl-d252ee1944404e15"
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.aws.id
  priority                = 1
}

resource "aws_route53_resolver_firewall_rule" "AWSManagedDomainsAmazonGuardDutyThreatList" {
  name                    = "AWSManagedDomainsAmazonGuardDutyThreatList"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = "rslvr-fdl-23584f0fb4c24ebb"
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.aws.id
  priority                = 2
}

resource "aws_route53_resolver_firewall_rule" "AWSManagedDomainsBotnetCommandandControl" {
  name                    = "AWSManagedDomainsBotnetCommandandControl"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = "rslvr-fdl-c80983a1f0284c99"
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.aws.id
  priority                = 3
}

resource "aws_route53_resolver_firewall_rule" "AWSManagedDomainsMalwareDomainList" {
  name                    = "AWSManagedDomainsMalwareDomainList"
  action                  = "BLOCK"
  block_response          = "NXDOMAIN"
  firewall_domain_list_id = "rslvr-fdl-fe17696f22a445f6"
  firewall_rule_group_id  = aws_route53_resolver_firewall_rule_group.aws.id
  priority                = 4
}
