resource "aws_s3_bucket_policy" "this" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.combined.json
}

data "aws_iam_policy_document" "combined" {
  source_policy_documents = concat(
    [data.aws_iam_policy_document.enforce_ssl_only.json],
    var.additional_policy_documents != null ? var.additional_policy_documents : []
  )
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
      var.bucket_arn,
      "${var.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
