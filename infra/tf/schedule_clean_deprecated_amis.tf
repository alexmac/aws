module "clean_deprecated_amis_assume_role" {
  source     = "./modules/iams/assume_role"
  account_id = data.aws_caller_identity.current.account_id
  services   = ["lambda.amazonaws.com"]
}

resource "aws_iam_role" "clean_deprecated_amis_role" {
  name               = "clean-deprecated-amis"
  assume_role_policy = module.clean_deprecated_amis_assume_role.policy_document
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]
}

resource "aws_iam_role_policy" "clean_deprecated_amis_role_policy" {
  name = "AMICleanup"
  role = aws_iam_role.clean_deprecated_amis_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeImages",
          "ec2:DeregisterImage",
          "ec2:DeleteSnapshot",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "clean_deprecated_amis_role" {
  role_name = aws_iam_role.clean_deprecated_amis_role.name
  policy_names = [
    aws_iam_role_policy.clean_deprecated_amis_role_policy.name,
  ]
}

module "scheduled_docker_lambda" {
  source             = "./modules/scheduled_docker_lambda"
  account_id         = data.aws_caller_identity.current.account_id
  region             = data.aws_region.current.name
  private_subnet_ids = module.vpc-usw2-10-0.private_subnet_ids
  vpc_id             = module.vpc-usw2-10-0.vpc_id
  lambda_role_arn    = aws_iam_role.clean_deprecated_amis_role.arn
  schedule_name      = "clean-deprecated-amis"
  docker_image       = "staging/cleanoldamis:134c8a91cf6bb67d0540990df99ab3bc9e5c06f5"
  schedules = {
    daily = {
      description               = "Deregisters any AMIs that have hit their deprecation time"
      maximum_window_in_minutes = 120
      schedule_expression       = "rate(1 day)"
      payload                   = {}
    }
  }
}
