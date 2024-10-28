module "assume_role_policy" {
  source     = "../../assume_role"
  account_id = var.account_id
  services   = ["scheduler.amazonaws.com"]
}

resource "aws_iam_role" "eventbridge_scheduler" {
  name               = "eventbridge-scheduler-${var.name}"
  assume_role_policy = module.assume_role_policy.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEventBridgeSchedulerFullAccess"
  ]
}

resource "aws_iam_role_policy" "this" {
  name = "RunTasks"
  role = aws_iam_role.eventbridge_scheduler.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecs:RunTask", "ecs:TagResource"]
        Resource = "*"
        Condition = {
          ArnLike = {
            "ecs:cluster" = var.ecs_cluster_arn
          }
        }
      },
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "this" {
  role_name = aws_iam_role.eventbridge_scheduler.name
  policy_names = [
    aws_iam_role_policy.this.name,
  ]
}
