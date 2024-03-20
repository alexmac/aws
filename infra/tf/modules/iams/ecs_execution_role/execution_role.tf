module "assume_role_policy" {
  source     = "../assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-execution-role"
  assume_role_policy = module.assume_role_policy.policy_document
  path               = "/"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]

  inline_policy {
    name = "Logs"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = ["logs:CreateLogGroup"]
          Resource = "*"
        }
      ]
    })
  }
}

