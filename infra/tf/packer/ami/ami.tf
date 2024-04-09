resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.cluster_name}/task/${var.ami_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = "packer-${var.ami_name}"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.packer_iam_role_arn
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "packer"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/packer:${local.packer_docker_image}"
      essential = true
      command   = var.docker_command
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

module "eventbridge_scheduler_role" {
  source          = "../../modules/iams/eventbridge/ecs_runtask_target"
  account_id      = var.account_id
  name            = "packer-scheduler-${var.ami_name}"
  ecs_cluster_arn = var.cluster_arn
}

resource "aws_scheduler_schedule" "this" {
  name        = "packer-${var.ami_name}"
  description = "packer for ami: ${var.ami_name}"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 120
  }

  schedule_expression = "rate(1 day)"

  target {
    arn      = var.cluster_arn
    role_arn = module.eventbridge_scheduler_role.arn

    ecs_parameters {
      launch_type = "FARGATE"
      network_configuration {
        assign_public_ip = false
        security_groups  = var.security_group_ids
        subnets          = var.private_subnet_ids
      }
      propagate_tags      = "TASK_DEFINITION"
      task_definition_arn = aws_ecs_task_definition.this.arn
    }
  }
}
