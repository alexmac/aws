data "aws_iam_policy_document" "policy" {
  dynamic "statement" {
    for_each = length(var.services) > 0 ? [var.services] : []
    content {
      actions = [
        "sts:AssumeRole",
        "sts:TagSession",
      ]
      effect = "Allow"
      principals {
        type        = "Service"
        identifiers = statement.value
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [var.account_id]
      }

      dynamic "condition" {
        for_each = length(var.source_arns) > 0 ? [var.source_arns] : []
        content {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = condition.value
        }
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
