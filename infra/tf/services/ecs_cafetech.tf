resource "aws_iam_role" "service_cafetech_role" {
  name = "service-cafetech"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  path = "/"
}

resource "aws_lb_target_group" "cafetech_target_group" {
  name     = "prod-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"
  }
}

resource "aws_ecs_task_definition" "cafetech" {
  family                   = "cafetech"
  cpu                      = "256"
  memory                   = "256"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = aws_iam_role.service_cafetech_role.arn

  container_definitions = jsonencode([
    {
      name      = "cafetech"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/cafetech:d7f3cd0ac4b4791371f8ff11ed8803901e15b033"
      essential = true
      portMappings = [
        {
          containerPort = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = "ecs-prod-cafetech"
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "cafetech" {
  name                               = "cafetech"
  cluster                            = "prod"
  task_definition                    = aws_ecs_task_definition.cafetech.arn
  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cafetech_target_group.arn
    container_name   = "cafetech"
    container_port   = 8080
  }
}
