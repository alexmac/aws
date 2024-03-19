module "clean_old_amis_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["lambda.amazonaws.com"]
}

resource "aws_iam_role" "clean_old_amis_role" {
  name               = "clean-old-amis"
  assume_role_policy = module.clean_old_amis_assume_role.policy_document
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policy {
    name = "AMICleanup"
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
}

resource "aws_security_group" "clean_old_amis_sg" {
  name        = "lambda-clean-old-amis"
  description = "Traffic from clean_old_amis"
  vpc_id      = var.vpc_id
  tags = {
    Name = "lambda-clean-old-amis"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "clean_old_amis" {
  function_name = "clean-old-amis"

  role = aws_iam_role.clean_old_amis_role.arn

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.clean_old_amis_sg.id]
  }

  timeout = 600

  architectures = ["arm64"]
  package_type  = "Image"

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/cleanoldamis:${local.clean_old_amis_docker_image}"
}

resource "aws_scheduler_schedule" "clean_old_amis_schedule" {
  name        = "clean-old-amis"
  description = "Deregisters any AMIs that have hit their deprecation time"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 120
  }

  schedule_expression = "rate(1 day)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:lambda:invoke"
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    input = jsonencode({
      FunctionName   = aws_lambda_function.clean_old_amis.arn,
      InvocationType = "Event",
      Payload = jsonencode({})
    })
  }
}
