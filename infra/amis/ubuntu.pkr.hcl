packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "latest-ubuntu-arm" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*-arm64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
}

data "amazon-ami" "latest-ubuntu-x86" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*-amd64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "ubuntu-arm" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-ami.latest-ubuntu-arm.id
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  launch_block_device_mappings {
      device_name = "/dev/sda1"
      encrypted = true
      volume_size = 32
      volume_type = "gp3"
      delete_on_termination = true
  }
  instance_type               = "t4g.xlarge"
  ssh_username                = "ubuntu"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "ubuntu arm {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "ubuntu arm {{timestamp}}"
  iam_instance_profile = "server"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-ubuntu-arm.id}"
  run_tags = {
    Name = "packer/ubuntu/{{timestamp}}/arm"
  }
  snapshot_tags = {
    Name = "packer/ubuntu/{{timestamp}}/arm"
  }
}

source "amazon-ebs" "ubuntu-x86" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-ami.latest-ubuntu-x86.id
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  launch_block_device_mappings {
      device_name = "/dev/sda1"
      encrypted = true
      volume_size = 32
      volume_type = "gp3"
      delete_on_termination = true
  }
  instance_type               = "t3a.xlarge"
  ssh_username                = "ubuntu"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "ubuntu x86 {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "ubuntu x86 {{timestamp}}"
  iam_instance_profile = "server"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-ubuntu-x86.id}"
  run_tags = {
    Name = "packer/ubuntu/{{timestamp}}/x86"
  }
  snapshot_tags = {
    Name = "packer/ubuntu/{{timestamp}}/x86"
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu-arm",
    "source.amazon-ebs.ubuntu-x86"
  ]

  provisioner "file" {
    source      = "shared"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "ubuntu_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/ubuntu_scripts/setup.sh"]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = ["sudo bash -xe /usr/local/ami_setup/ubuntu_scripts/setup_2.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }

  post-processor "manifest" {
    output     = "output/ubuntu_manifest.json"
    strip_path = true
  }
}
