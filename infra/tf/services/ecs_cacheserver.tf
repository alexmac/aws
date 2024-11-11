module "cacheserver_assume_role" {
  source     = "../modules/iams/assume_role"
  account_id = var.account_id
  services   = ["ecs-tasks.amazonaws.com"]
}

resource "aws_iam_role" "service_cacheserver" {
  name               = "service-cacheserver"
  assume_role_policy = module.cacheserver_assume_role.policy_document
  path               = "/"
}

resource "aws_iam_role_policy" "service_cacheserver" {
  name = "InvokeLambda"
  role = aws_iam_role.service_cacheserver.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ]
        Resource = "${module.cacheserver_s3_bucket.bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
        ]
        Resource = module.cacheserver_s3_bucket.bucket_arn
      }
    ]
  })
}

resource "aws_iam_role_policies_exclusive" "service_cacheserver" {
  role_name = aws_iam_role.service_cacheserver.name
  policy_names = [
    aws_iam_role_policy.service_cacheserver.name,
  ]
}


resource "aws_lb_target_group" "cacheserver_target_group" {
  name     = "prod-internal-cacheserver"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled  = true
    path     = "/health"
    protocol = "HTTP"
    port     = "traffic-port"
  }
}

resource "aws_lb_listener_rule" "cacheserver_listener_rule" {
  listener_arn = aws_lb_listener.internal_alb.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.cacheserver_target_group.arn
  }

  condition {
    host_header {
      values = ["cache.0xcafe.tech"]
    }
  }
}

resource "aws_cloudwatch_log_group" "cacheserver_logs" {
  name              = "/ecs/prod/service/cacheserver"
  retention_in_days = 7
  kms_key_id        = var.kms_cloudtrailwatch_arn
}

resource "aws_ecs_task_definition" "cacheserver" {
  family                   = "cacheserver"
  cpu                      = "256"
  memory                   = "256"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = aws_iam_role.service_cacheserver.arn

  container_definitions = jsonencode([
    {
      name      = "cacheserver"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/cacheserver:97f30a2c82c62509890fee56dd562f1d5e8af4f9"
      essential = true
      portMappings = [
        {
          containerPort = 8080
        }
      ],
      "environment" = [
        { "name" = "ALLOWED_REMOTE_HOSTS", "value" = "deb.debian.org,.*.download.nvidia.com,.*.archive.ubuntu.com,security.ubuntu.com,.*.ports.ubuntu.com" },
        { "name" = "AWS_CLOUDWATCH_LOG_GROUP", "value" = aws_cloudwatch_log_group.cacheserver_logs.name },
        { "name" = "AWS_REGION", "value" = "${var.region}" },
        { "name" = "GIN_MODE", "value" = "release" },
        { "name" = "PORT", "value" = "8080" },
        { "name" = "S3_BUCKET", "value" = module.cacheserver_s3_bucket.bucket_id },
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.cacheserver_logs.name
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "cacheserver" {
  name                               = "cacheserver"
  cluster                            = "prod"
  task_definition                    = aws_ecs_task_definition.cacheserver.arn
  launch_type                        = "EC2"
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  ordered_placement_strategy {
    field = "memory"
    type  = "binpack"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.cacheserver_target_group.arn
    container_name   = "cacheserver"
    container_port   = 8080
  }
}
