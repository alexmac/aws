module "cloudwatch_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["cloudtrail.amazonaws.com"]
}

resource "aws_iam_role" "cloudwatch_logs_role" {
  name               = "alerting-cloudwatch"
  assume_role_policy = module.cloudwatch_assume_role.policy_document
  path               = "/"

  inline_policy {
    name = "CloudWatchLogsPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
        },
      ]
    })
  }
}

resource "aws_sns_topic" "cis_alarms" {
  name = "cis-alarms-topic"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "cis_alarms_subscription" {
  topic_arn = aws_sns_topic.cis_alarms.arn
  protocol  = "email"
  endpoint  = "alex@alexmac.cc"
}
