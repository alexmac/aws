
resource "aws_launch_template" "processing_launch_template" {
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

  instance_type = "c7g.large"


  instance_market_options {
    market_type = "spot"
    spot_options {
      max_price          = 0.04
      spot_instance_type = "one-time"
    }
  }

  monitoring {
    enabled = false
  }

  network_interfaces {
    security_groups = [
      aws_security_group.processing_sg.id,
      aws_security_group.processing_xray.id,
      var.tailscale_ssh_access_sg,

    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ephemeral-server"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "ephemeral-server"
    }
  }

  user_data = base64encode(<<EOT
#!/bin/bash -xe
mkdir -p /etc/ecs
cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=processing
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

resource "aws_autoscaling_group" "processing_asg" {
  name                = "processing-asg-${var.vpc_id}"
  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = 0
  max_size         = 2
  min_size         = 0

  launch_template {
    id      = aws_launch_template.processing_launch_template.id
    version = "$Latest"
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

  # mixed_instances_policy {
  #   instances_distribution {
  #     on_demand_base_capacity                  = 0
  #     on_demand_percentage_above_base_capacity = 0
  #     spot_allocation_strategy                 = "price-capacity-optimized"
  #   }

  #   launch_template {
  #     launch_template_specification {
  #       launch_template_id = aws_launch_template.processing_launch_template.id
  #     }

  #     override {
  #       instance_type     = "c7g.medium"
  #       weighted_capacity = "1"
  #     }

  #     override {
  #       instance_type     = "c7gn.medium"
  #       weighted_capacity = "1"
  #     }

  #     override {
  #       instance_type     = "c6g.medium"
  #       weighted_capacity = "1"
  #     }

  #     override {
  #       instance_type     = "c6gn.medium"
  #       weighted_capacity = "1"
  #     }
  #   }
  # }
}

# resource "aws_ecs_capacity_provider" "processing_ecs_capacity_provider" {
#   name = "processing-capacityprovider-${var.vpc_id}"

#   auto_scaling_group_provider {
#     auto_scaling_group_arn = aws_autoscaling_group.processing_asg.arn
#     managed_scaling {
#       status                    = "ENABLED"
#       target_capacity           = 100
#       minimum_scaling_step_size = 1
#       maximum_scaling_step_size = 2
#     }
#     managed_termination_protection = "ENABLED"
#   }
# }

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "processing"
}

# resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cap_provider_assoc" {
#   cluster_name       = aws_ecs_cluster.ecs_cluster.name
#   capacity_providers = ["processing-capacityprovider-${var.vpc_id}"]
#   default_capacity_provider_strategy {
#     capacity_provider = "processing-capacityprovider-${var.vpc_id}"
#   }
# }
