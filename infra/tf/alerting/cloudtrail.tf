resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cafetech-cloudtrail-security-hub"
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

data "aws_iam_policy_document" "cloudtrail" {
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
      aws_s3_bucket.cloudtrail.arn,
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
      "${aws_s3_bucket.cloudtrail.arn}/*",
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
      "${aws_s3_bucket.cloudtrail.arn}/*",
    ]
  }

  statement {
    sid    = "ssl_access_only"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }

    resources = [
      aws_s3_bucket.cloudtrail.arn,
      "${aws_s3_bucket.cloudtrail.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    id = "expiration"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    expiration {
      days = 7
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/cis-logs"
  retention_in_days = 7
  kms_key_id        = var.kms_arn
}

resource "aws_cloudtrail" "main" {
  name                          = "securityhub-cis-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_logs_role.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  kms_key_id                    = var.kms_arn
}
