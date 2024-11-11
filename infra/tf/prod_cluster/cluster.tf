
resource "aws_launch_template" "prod_launch_template" {
  name_prefix            = "lt-${var.vpc_id}-"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  }

  ebs_optimized = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.server_ec2_instance_profile.arn
  }

  image_id = "resolve:ssm:/amis/server"

  instance_type = "t4g.small"

  monitoring {
    enabled = false
  }

  network_interfaces {
    security_groups = [
      aws_security_group.prod_sg.id,
      aws_security_group.prod_xray.id,
      aws_security_group.prod_otel.id,
      aws_security_group.alb_container_ingress.id,
      var.tailscale_ssh_access_sg,

    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "server"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "server"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name = "server"
    }
  }

  user_data = base64encode(<<EOT
#!/bin/bash -xe
mkdir -p /etc/ecs
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=prod
ECS_ENABLE_TASK_ENI=true
ECS_ENABLE_TASK_IAM_ROLE=true
ECS_LOG_MAX_FILE_SIZE_MB=100
ECS_LOG_MAX_ROLL_COUNT=3
ECS_LOG_ROLLOVER_TYPE=size
ECS_LOGLEVEL=info
ECS_AVAILABLE_LOGGING_DRIVERS=["awslogs","json-file"]
EOF
EOT
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = false
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "resource-name"
  }
}

resource "aws_autoscaling_group" "prod_asg" {
  name                = "prod-asg-${var.vpc_id}"
  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = 1
  max_size         = 3
  min_size         = 1

  launch_template {
    id      = aws_launch_template.prod_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "prod-asg-${var.vpc_id}"
    propagate_at_launch = false
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  protect_from_scale_in = true
  instance_maintenance_policy {
    max_healthy_percentage = 200
    min_healthy_percentage = 100
  }
}

resource "aws_ecs_capacity_provider" "prod_ecs_capacity_provider" {
  name = "prod-capacityprovider-${var.vpc_id}"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.prod_asg.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
    managed_termination_protection = "ENABLED"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "prod"

  tags = {
    Name = "prod-ecs-cluster-${var.vpc_id}"
  }
}

# resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cap_provider_assoc" {
#   cluster_name       = aws_ecs_cluster.ecs_cluster.name
#   capacity_providers = ["prod-capacityprovider-${var.vpc_id}"]
#   default_capacity_provider_strategy {
#     capacity_provider = "prod-capacityprovider-${var.vpc_id}"
#   }
# }
