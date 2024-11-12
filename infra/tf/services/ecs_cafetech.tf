module "cafetech_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services = [
    "ecs-tasks.amazonaws.com",
    "pods.eks.amazonaws.com",
  ]
}

resource "aws_iam_role" "service_cafetech_role" {
  name               = "service-cafetech"
  assume_role_policy = module.cafetech_assume_role.policy_document
  path               = "/"
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

resource "aws_lb_listener_rule" "cafetech_listener_rule" {
  listener_arn = aws_lb_listener.prod_alb.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cafetech_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_cloudwatch_log_group" "cafetech_logs" {
  name              = "/ecs/prod/service/cafetech"
  retention_in_days = 7
  kms_key_id        = var.kms_cloudtrailwatch_arn
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
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/cafetech:64cc950888f50abb950de89f45a3b27b3426590f"
      essential = true
      portMappings = [
        {
          containerPort = 8080
        }
      ],
      "environment" = [
        { "name" = "AWS_CLOUDWATCH_LOG_GROUP", "value" = aws_cloudwatch_log_group.cafetech_logs.name }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.cafetech_logs.name
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
