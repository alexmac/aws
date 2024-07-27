module "cooltrans_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "service_cooltrans" {
  name               = "service-cooltrans"
  assume_role_policy = module.cooltrans_assume_role.policy_document
  path               = "/"
}

resource "aws_lb_target_group" "cooltrans_target_group" {
  name     = "prod-cooltrans"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"
  }
}

resource "aws_lb_listener_rule" "cooltrans_listener_rule" {
  listener_arn = aws_lb_listener.prod_alb.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cooltrans_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/api/cooltrans/*"]
    }
  }
}

resource "aws_cloudwatch_log_group" "cooltrans_logs" {
  name              = "/ecs/prod/service/cooltrans"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "cooltrans" {
  family                   = "cooltrans"
  cpu                      = "256"
  memory                   = "256"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = aws_iam_role.service_cooltrans.arn

  container_definitions = jsonencode([
    {
      name      = "cooltrans"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/cooltrans:b944bc1ca33df51dd151c5c0a2cdb9d46947ca07"
      essential = true
      portMappings = [
        {
          containerPort = 8081
        }
      ],
      "environment" = [
        { "name" = "AWS_CLOUDWATCH_LOG_GROUP", "value" = aws_cloudwatch_log_group.cooltrans_logs.name }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.cooltrans_logs.name
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "cooltrans" {
  name                               = "cooltrans"
  cluster                            = "prod"
  task_definition                    = aws_ecs_task_definition.cooltrans.arn
  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cooltrans_target_group.arn
    container_name   = "cooltrans"
    container_port   = 8081
  }
}
