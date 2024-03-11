module "eventbridge_scheduler_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["scheduler.amazonaws.com", "events.amazonaws.com"]
}

resource "aws_iam_role" "eventbridge_scheduler" {
  name               = "instancerefresh-eventbridge-scheduler"
  assume_role_policy = module.eventbridge_scheduler_assume_role.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policy {
    name = "Logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "logs:CreateLogGroup"
          Resource = "*"
        }
      ]
    })
  }
}
