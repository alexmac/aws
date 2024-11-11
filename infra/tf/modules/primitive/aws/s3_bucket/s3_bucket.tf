resource "aws_s3_bucket" "this" {
  bucket        = var.add_random_suffix ? "${var.bucket_name}-${random_string.bucket_suffix[0].result}" : var.bucket_name
  force_destroy = var.force_destroy
}

resource "random_string" "bucket_suffix" {
  count   = var.add_random_suffix ? 1 : 0
  length  = 12
  special = false
  upper   = false
}

resource "aws_s3_bucket_policy" "this" {
  count  = var.override_bucket_policy ? 0 : 1
  bucket = aws_s3_bucket.this.id
  policy = var.override_bucket_policy ? null : data.aws_iam_policy_document.enforce_ssl_only.json
}

data "aws_iam_policy_document" "enforce_ssl_only" {
  statement {
    sid    = "EnforceSSLOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.encryption_enabled ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  count  = var.block_public_access ? 1 : 0
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
