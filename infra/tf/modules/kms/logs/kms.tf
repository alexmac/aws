resource "aws_kms_key" "this" {
  description             = "Encryption at rest for cloudtrail/cloudwatch"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "this" {
  name          = "alias/cloudwatch-cloudtrail"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.this.id
  policy = jsonencode({
    "Id" = "AWS Usage",
    "Statement" = [
      {
        "Sid"    = "Enable IAM User Permissions",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = [
            "arn:aws:iam::${var.account_id}:root"
          ]
        },
        "Action"   = "kms:*",
        "Resource" = "*"
      },
      {
        "Sid"    = "Allow CloudTrail to encrypt logs",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "cloudtrail.amazonaws.com"
        },
        "Action"   = "kms:GenerateDataKey*",
        "Resource" = "*",
        "Condition" = {
          "ArnLike" = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${var.region}:${var.account_id}:trail/*"
          }
        }
      },
      {
        "Sid"    = "Allow CloudTrail to describe key",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "cloudtrail.amazonaws.com"
        },
        "Action"   = "kms:DescribeKey",
        "Resource" = "*"
      },
      {
        "Sid"    = "Enable cross account log decryption",
        "Effect" = "Allow",
        "Principal" = {
          "AWS" = "*"
        },
        "Action" = [
          "kms:Decrypt",
          "kms:ReEncryptFrom"
        ],
        "Resource" = "*",
        "Condition" = {
          "StringEquals" = {
            "kms:CallerAccount" = "${var.account_id}"
          }
        },
      },
      {
        "Sid"    = "Cloudwatch usage",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "logs.${var.region}.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ],
        "Resource" = "*",
        "Condition" = {
          "ArnLike" = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.region}:${var.account_id}:log-group:*"
          }
        }
      },
      {
        "Sid"    = "S3 usage",
        "Effect" = "Allow",
        "Principal" = {
          "Service" = "s3.amazonaws.com"
        },
        "Action" = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*",
        ],
        "Resource" = "*"
      }
    ]
    Version = "2012-10-17"
  })
}
