module "xray_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "service_xray" {
  name               = "service-xray"
  assume_role_policy = module.xray_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy_attachments_exclusive" "service_xray" {
  role_name = aws_iam_role.service_xray.name
  policy_arns = [
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess",
  ]
}

resource "aws_cloudwatch_log_group" "xray_logs" {
  name              = "/ecs/prod/service/xray"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "xray" {
  family                   = "xray"
  cpu                      = "256"
  memory                   = "256"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = aws_iam_role.service_xray.arn

  container_definitions = jsonencode([
    {
      name      = "xray"
      image     = "public.ecr.aws/xray/aws-xray-daemon:3.x"
      essential = true
      portMappings = [
        {
          "hostPort"      = 40000,
          "containerPort" = 2000,
          "protocol"      = "udp"
        },
        {
          "hostPort"      = 40000,
          "containerPort" = 2000,
          "protocol"      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.xray_logs.name
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "xray" {
  name                               = "xray"
  cluster                            = "prod"
  task_definition                    = aws_ecs_task_definition.xray.arn
  scheduling_strategy                = "DAEMON"
  launch_type                        = "EC2"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
}
