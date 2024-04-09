locals {
  arn_base = "arn:aws:securityhub:${var.region}:${var.account_id}:control"
}
# resource "aws_securityhub_account" "this" {}

# resource "aws_securityhub_standards_subscription" "cis-aws-foundations-benchmark_v_1-2-0" {
#   standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
#   depends_on    = [aws_securityhub_account.this]
# }
