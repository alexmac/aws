module "eventbridge_scheduler_assume_role" {
  source     = "../iams/assume_role"
  account_id = var.account_id
  services   = ["scheduler.amazonaws.com"]
}

resource "aws_iam_role" "this" {
  name               = "eventbridge-scheduler-${var.schedule_name}"
  assume_role_policy = module.eventbridge_scheduler_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "this" {
  role_name = aws_iam_role.this.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess",
  ]
}

resource "aws_iam_role_policy" "this" {
  name = "InvokeLambda"
  role = aws_iam_role.this.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = module.lambda.lambda_arn
      }
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "this" {
  role_name = aws_iam_role.this.name
  policy_names = [
    aws_iam_role_policy.this.name,
  ]
}