data "aws_iam_policy_document" "policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:*:${var.account_id}:trail/*"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }
}

resource "aws_iam_role" "cloudwatch_logs_role" {
  name               = "alerting-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.policy.json
  path               = "/"

  inline_policy {
    name = "CloudWatchLogsPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Sid" = "LogUsage",
          Action = [
            "logs:CreateLogStream",
            "logs:DescribeLogGroups",
            "logs:DescribeLogStreams",
            "logs:PutLogEvents",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_cloudwatch_log_group.cloudtrail.arn}:*",
          ]
        },

        {
          "Sid"    = "KMSUsage",
          "Effect" = "Allow",
          "Action" = [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*",
          ],
          "Resource" = var.kms_arn,
        }

      ]
    })
  }
}

resource "aws_sns_topic" "cis_alarms" {
  name              = "cis-alarms-topic"
  kms_master_key_id = var.kms_arn

}

resource "aws_sns_topic_subscription" "cis_alarms_subscription" {
  topic_arn = aws_sns_topic.cis_alarms.arn
  protocol  = "email"
  endpoint  = "alex@alexmac.cc"
}
