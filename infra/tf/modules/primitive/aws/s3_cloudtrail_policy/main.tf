data "aws_iam_policy_document" "cloudtrail_policy" {
  statement {
    sid = "CloudTrailPutObject"
    principals {
      type = "AWS"
      identifiers = [
        data.aws_elb_service_account.main.arn
      ]
    }
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${var.bucket_arn}/AWSLogs/${var.account_id}/*",
    ]
  }
}

data "aws_elb_service_account" "main" {}