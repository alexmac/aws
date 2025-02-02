resource "aws_launch_template" "gpu_launch_template" {
  name_prefix            = "lt-"
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 500
      volume_type           = "gp3"
    }
  }

  ebs_optimized = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.gpu_ec2_instance_profile.arn
  }

  image_id = "resolve:ssm:/amis/ubuntu/x86"

  instance_type = "g6e.xlarge"

  monitoring {
    enabled = false
  }

  network_interfaces {
    security_groups = [
      aws_security_group.gpu_sg.id,
      aws_security_group.gpu_ollama_access.id,
      var.tailscale_ssh_access_sg
    ]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "gpu"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "gpu"
    }
  }

  tag_specifications {
    resource_type = "network-interface"
    tags = {
      Name = "gpu"
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

resource "aws_autoscaling_group" "gpu_asg" {
  name                = "gpu-asg-${var.vpc_id}"
  vpc_zone_identifier = var.private_subnet_ids

  desired_capacity = 0
  max_size         = 3
  min_size         = 0

  tag {
    key                 = "Name"
    value               = "gpu-asg-${var.vpc_id}"
    propagate_at_launch = false
  }

  launch_template {
    id      = aws_launch_template.gpu_launch_template.id
    version = "$Latest"
  }
}
