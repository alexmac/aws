resource "aws_ecs_task_definition" "packer_tailscale_task_def" {
  family                   = "packer-tailscale"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = aws_iam_role.packer.arn
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  container_definitions = jsonencode([
    {
      name      = "packer"
      image     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/staging/packer:${local.packer_docker_image}"
      essential = true
      command   = ["make", "tailscale"]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-create-group"  = "true"
          "awslogs-group"         = "ecs-packer-tailscale"
          "awslogs-region"        = "${var.region}"
          "awslogs-stream-prefix" = "ecs-logs"
        }
      }
    }
  ])
}

resource "aws_scheduler_schedule" "tailscale_ami_schedule" {
  name        = "packer-tailscale"
  description = "packer for tailscale ami"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 120
  }

  schedule_expression = "rate(1 day)"

  target {
    arn      = aws_ecs_cluster.packer.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn

    ecs_parameters {
      launch_type = "FARGATE"
      network_configuration {
        assign_public_ip = false
        security_groups = [
          aws_security_group.packer_fargate.arn
        ]
        subnets = var.private_subnet_ids
      }
      propagate_tags      = "TASK_DEFINITION"
      task_definition_arn = aws_ecs_task_definition.packer_tailscale_task_def.arn
    }
  }
}
