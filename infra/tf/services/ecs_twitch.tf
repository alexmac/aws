module "twitch_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "service_twitch" {
  name               = "service-twitch"
  assume_role_policy = module.twitch_assume_role.policy_document
  path               = "/"


  inline_policy {
    name = "secret-access"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ]
          Resource = [
            "arn:aws:secretsmanager:${var.region}:${var.account_id}:secret:twitch/*"
          ]
          Effect = "Allow"
        },
      ]
    })
  }
}

resource "aws_cloudwatch_log_group" "twitch_logs" {
  name              = "/ecs/processing/service/twitch"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "twitch" {
  family                   = "twitch"
  cpu                      = "256"
  memory                   = "1024"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = aws_iam_role.service_twitch.arn

  container_definitions = jsonencode([
    {
      name      = "twitch"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/twitch:7cfa4756921ff42c8708f54d08d40066b4ef70df"
      essential = true
      "environment" = [
        {"name" = "AWS_CLOUDWATCH_LOG_GROUP", "value" = aws_cloudwatch_log_group.twitch_logs.name},
        {"name" = "AWS_DEFAULT_REGION", "value" = var.region },
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.twitch_logs.name
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "twitch" {
  name                               = "twitch"
  cluster                            = "processing"
  task_definition                    = aws_ecs_task_definition.twitch.arn
  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 0

  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }
}
