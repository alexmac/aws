resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "cacheserver" {
  bucket = "${var.region}-cacheserver-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_policy" "cacheserver" {
  bucket = aws_s3_bucket.cacheserver.id
  policy = data.aws_iam_policy_document.cacheserver.json
}

data "aws_iam_policy_document" "cacheserver" {

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
      aws_s3_bucket.cacheserver.arn,
      "${aws_s3_bucket.cacheserver.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cacheserver" {
  bucket = aws_s3_bucket.cacheserver.id

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

resource "aws_s3_bucket_versioning" "cacheserver" {
  bucket = aws_s3_bucket.cacheserver.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cacheserver" {
  bucket                  = aws_s3_bucket.cacheserver.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}