resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = var.bucket_id

  rule {
    id = "7day-expiration"

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