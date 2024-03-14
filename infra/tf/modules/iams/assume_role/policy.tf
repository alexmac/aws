data "aws_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = length(var.services) > 0 ? [var.services] : []
    content {
      actions = ["sts:AssumeRole"]
      effect  = "Allow"
      principals {
        type        = "Service"
        identifiers = statement.value
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [var.account_id]
      }
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
