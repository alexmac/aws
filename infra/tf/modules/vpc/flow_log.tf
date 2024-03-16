resource "aws_flow_log" "flow_log" {
  iam_role_arn    = aws_iam_role.flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpc.id

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/vpc/flow-logs/${aws_vpc.vpc.id}"
  retention_in_days = 7
}

module "flow_log_assume_role" {
  source     = "../../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["vpc-flow-logs.amazonaws.com"]
}

resource "aws_iam_role" "flow_log_role" {
  name               = "vpc-flow-logs-${aws_vpc.vpc.id}"
  assume_role_policy = module.flow_log_assume_role.policy_document
  path               = "/"

  inline_policy {
    name = "logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
          ]
          Resource = [
            aws_cloudwatch_log_group.log_group.arn,
            "${aws_cloudwatch_log_group.log_group.arn}:*",
          ]
        },
      ]
    })
  }
}
