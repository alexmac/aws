
resource "aws_launch_template" "github_launch_template" {
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
    arn = aws_iam_instance_profile.github_ec2_instance_profile.arn
  }

  image_id = "resolve:ssm:/amis/github"

  instance_type = "t4g.small"

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
      aws_security_group.github_sg.id,
      aws_security_group.github_xray.id,
      var.tailscale_ssh_access_sg,

    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "github"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "github"
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo "More to come here"
EOF
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

resource "aws_autoscaling_group" "github_asg" {
  name                = "github-asg-${var.vpc_id}"
  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = 1
  max_size         = 2
  min_size         = 1

  launch_template {
    id      = aws_launch_template.github_launch_template.id
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
}
