resource "aws_s3_bucket" "cloudtrail" {
  bucket = "cafetech-cloudtrail-security-hub"
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
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
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.account_id}/*",
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
  name = "/aws/cloudtrail/cis-logs"
  retention_in_days = 7
}

resource "aws_kms_key" "this" {
  description             = "securityhub-cis-cloudtrail"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "this" {
  name          = "alias/securityhub-cis-cloudtrail"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    "Id" = "Key policy created by CloudTrail",
    "Statement" = [
        {
            "Sid" = "Enable IAM User Permissions",
            "Effect" = "Allow",
            "Principal" = {
                "AWS" = [
                    "arn:aws:iam::${var.account_id}:root"
                ]
            },
            "Action" = "kms:*",
            "Resource" = "*"
        },
        {
            "Sid" = "Allow CloudTrail to encrypt logs",
            "Effect" = "Allow",
            "Principal" = {
                "Service" = "cloudtrail.amazonaws.com"
            },
            "Action" = "kms:GenerateDataKey*",
            "Resource" = "*",
            "Condition" = {
                "StringEquals" = {
                    "aws:SourceArn" = "arn:aws:cloudtrail:${var.region}:${var.account_id}:trail/securityhub-cis-cloudtrail"
                },
                "StringLike" = {
                    "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:aws:cloudtrail:*:${var.account_id}:trail/*"
                }
            }
        },
        {
            "Sid" = "Allow CloudTrail to describe key",
            "Effect" = "Allow",
            "Principal" = {
                "Service" = "cloudtrail.amazonaws.com"
            },
            "Action" =  "kms:DescribeKey",
            "Resource" = "*"
        },
        {
            "Sid"=  "Enable cross account log decryption",
            "Effect"= "Allow",
            "Principal"= {
                "AWS"= "*"
            },
            "Action"= [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource"= "*",
            "Condition"= {
                "StringEquals": {
                    "kms:CallerAccount"= "${var.account_id}"
                },
                "StringLike"= {
                    "kms:EncryptionContext:aws:cloudtrail:arn"= "arn:aws:cloudtrail:*:${var.account_id}:trail/*"
                }
            }
        }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_cloudtrail" "main" {
  name                          = "securityhub-cis-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail.arn}:*"
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_logs_role.arn
  include_global_service_events = true
  is_multi_region_trail         = true
  kms_key_id                    = aws_kms_key.this.arn
}
