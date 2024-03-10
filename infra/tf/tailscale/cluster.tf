resource "aws_launch_template" "tailscale_launch_template" {
  name_prefix            = "lt-"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  }

  ebs_optimized = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.tailscale_ec2_instance_profile.arn
  }

  image_id = "resolve:ssm:/amis/tailscale"

  instance_type = "t4g.micro"

  monitoring {
    enabled = false
  }

  network_interfaces {
    security_groups = [aws_security_group.tailscale_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "tailscale"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "tailscale"
    }
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo "More to come here"
EOF
  )

  metadata_options {
    http_tokens = "required"
  }

  private_dns_name_options {
    enable_resource_name_dns_aaaa_record = false
    enable_resource_name_dns_a_record    = true
    hostname_type                        = "resource-name"
  }
}

resource "aws_autoscaling_group" "tailscale_asg" {
  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = 1
  max_size         = 3
  min_size         = 1

  launch_template {
    id      = aws_launch_template.tailscale_launch_template.id
    version = "$Latest"
  }
}

output "tailscale_ssh_access_sg" {
  value       = aws_security_group.tailscale_ssh_access.id
  description = "SG that allows tailscale SSH access"
}