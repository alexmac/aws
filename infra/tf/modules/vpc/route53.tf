# Query via log insights using:
# fields @timestamp, query_name 
# | filter query_name not like "amazonaws.com"
# | filter query_name not like "compute.internal"
# | stats count() as queryCount by query_name 
# | sort queryCount desc 
# | limit 100

resource "aws_route53_resolver_query_log_config" "this" {
  name            = "query-logging-for-${aws_vpc.vpc.id}"
  destination_arn = aws_cloudwatch_log_group.this.arn
}

resource "aws_route53_resolver_query_log_config_association" "example" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.this.id
  resource_id                  = aws_vpc.vpc.id
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/route53/resolver/${aws_vpc.vpc.id}"
  retention_in_days = 7
}
