module "eventbridge_scheduler_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["scheduler.amazonaws.com"]
}

resource "aws_iam_role" "eventbridge_scheduler" {
  name               = "clean-old-amis-eventbridge-scheduler"
  assume_role_policy = module.eventbridge_scheduler_assume_role.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess",
  ]
  inline_policy {
    name = "InvokeLambda"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["lambda:InvokeFunction"]
          Resource = aws_lambda_function.clean_old_amis.arn
        }
      ]
    })
  }
}
