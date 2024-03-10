data "aws_iam_policy_document" "instancerefresh_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.account_id]
    }
  }
}

resource "aws_iam_role" "instancerefresh_role" {
  name               = "instancerefresh"
  assume_role_policy = data.aws_iam_policy_document.instancerefresh_assume_role.json
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
  ]

  inline_policy {
    name = "RefreshPolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DetachInstances",
            "ec2:TerminateInstances",
            "ecs:DescribeClusters",
            "ecs:DescribeContainerInstances",
            "ecs:ListClusters",
            "ecs:ListContainerInstances",
            "ecs:UpdateContainerInstancesState",
          ]
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_security_group" "instancerefresh_sg" {
  name        = "lambda-instancerefresh"
  description = "Traffic from instancerefresh"
  vpc_id      = var.vpc_id
  tags = {
    Name = "lambda-instancerefresh"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "instancerefresh" {
  function_name = "instancerefresh"

  role = aws_iam_role.instancerefresh_role.arn
  # handler = "index.handler" # This is required but not used for container image.

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.instancerefresh_sg.id]
  }

  timeout = 600

  architectures = ["arm64"]
  package_type  = "Image"

  image_uri = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/instancerefresh:${local.instance_refresh_docker_image}"

  environment {
    variables = {
      # Define environment variables if needed
    }
  }
}

resource "aws_scheduler_schedule" "instancerefresh_schedule_prod_asg" {
  name        = "instancerefresh-prod-asg"
  description = "prod asg instance refresh"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 120
  }

  schedule_expression = "rate(1 day)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:lambda:invoke"
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    input = jsonencode({
      FunctionName   = aws_lambda_function.instancerefresh.arn,
      InvocationType = "Event",
      Payload = jsonencode({
        asg_name    = var.prod_asg,
        cluster_arn = var.prod_cluster_arn,
      })
    })
  }
}

resource "aws_scheduler_schedule" "instancerefresh_schedule_tailscale_asg" {
  name        = "instancerefresh-tailscale-asg"
  description = "tailscale asg instance refresh"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 120
  }

  schedule_expression = "rate(1 day)"

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:lambda:invoke"
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    input = jsonencode({
      FunctionName   = aws_lambda_function.instancerefresh.arn,
      InvocationType = "Event",
      Payload = jsonencode({
        asg_name    = var.tailscale_asg,
        cluster_arn = "",
      })
    })
  }
}
