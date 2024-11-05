module "assume_role_policy" {
  source     = "../assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "ecs-execution-role"
  assume_role_policy = module.assume_role_policy.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "ecs_execution_role" {
  role_name = aws_iam_role.ecs_execution_role.name
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]
}

resource "aws_iam_role_policy" "this" {
  name = "Logs"
  role = aws_iam_role.ecs_execution_role.name
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

resource "aws_iam_role_policies_exclusive" "this" {
  role_name = aws_iam_role.ecs_execution_role.name
  policy_names = [
    aws_iam_role_policy.this.name,
  ]
}
