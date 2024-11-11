module "cloudtrail_s3_bucket" {
  source                 = "../modules/primitive/aws/s3_bucket"
  bucket_name            = "cafetech-cloudtrail-security-hub"
  override_bucket_policy = true
}

module "cloudtrail_s3_bucket_lifecycle" {
  source    = "../modules/primitive/aws/7day_lifecycle"
  bucket_id = module.cloudtrail_s3_bucket.bucket_id
}

module "cloudtrail_s3_bucket_policy" {
  source     = "../modules/primitive/aws/s3_bucket_policy"
  bucket_id  = module.cloudtrail_s3_bucket.bucket_id
  bucket_arn = module.cloudtrail_s3_bucket.bucket_arn
  additional_policy_documents = [
    data.aws_iam_policy_document.cloudtrail_policy.json
  ]
}

data "aws_iam_policy_document" "cloudtrail_policy" {
  statement {
    sid = "cloudtrail_access"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      module.cloudtrail_s3_bucket.bucket_arn
    ]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:cloudtrail:${var.region}:${var.account_id}:trail/*"]
      variable = "aws:SourceArn"
    }
  }

  statement {
    sid = "cloudtrail_puts"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
    condition {
      test     = "StringEquals"
      values   = [var.account_id]
      variable = "aws:SourceAccount"
    }
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${module.cloudtrail_s3_bucket.bucket_arn}/*",
    ]
  }

  statement {
    sid = "cloudtrail_gets"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "s3:GetObject"
    ]
    condition {
      test     = "StringEquals"
      values   = [var.account_id]
      variable = "aws:SourceAccount"
    }
    resources = [
      "${module.cloudtrail_s3_bucket.bucket_arn}/*",
    ]
  }
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/cis-logs"
  retention_in_days = 7
  kms_key_id        = var.kms_arn
}

resource "aws_cloudtrail" "main" {
  name                          = "securityhub-cis-cloudtrail"
  s3_bucket_name                = module.cloudtrail_s3_bucket.bucket_id
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_logs_role.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_arn
}
