packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

# aws ec2 describe-images --owners 137112412989 --filters "Name=name,Values=al2023-ami-minimal-2023.*-arm64"

data "amazon-ami" "latest-al2023-arm" {
  filters = {
    virtualization-type = "hvm"
    name                = "al2023-ami-minimal-2023.*-arm64"
    root-device-type    = "ebs"
  }
  owners      = ["137112412989"]
  most_recent = true
}

# aws ec2 describe-images --owners 137112412989 --filters "Name=name,Values=al2023-ami-minimal-2023.*-x86_64"

data "amazon-ami" "latest-al2023-x86" {
  filters = {
    virtualization-type = "hvm"
    name                = "al2023-ami-minimal-2023.*-x86_64"
    root-device-type    = "ebs"
  }
  owners      = ["137112412989"]
  most_recent = true
}

source "amazon-ebs" "server-arm" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-ami.latest-al2023-arm.id
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  instance_type               = "t4g.small"
  ssh_username                = "ec2-user"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "server arm {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "server arm {{timestamp}}"
  iam_instance_profile = "server"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-al2023-arm.id}"
  run_tags = {
    Name = "packer building: server arm {{timestamp}}"
  }
  snapshot_tags = {
    Name = "server arm {{timestamp}}"
  }
}

source "amazon-ebs" "server-x86" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-ami.latest-al2023-x86.id
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  instance_type               = "t3a.small"
  ssh_username                = "ec2-user"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "server x86 {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "server x86 {{timestamp}}"
  iam_instance_profile = "server"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-al2023-x86.id}"
  run_tags = {
    Name = "packer building: server x86 {{timestamp}}"
  }
  snapshot_tags = {
    Name = "server x86 {{timestamp}}"
  }
}

build {
  sources = [
    "source.amazon-ebs.server-arm",
    "source.amazon-ebs.server-x86"
  ]

  provisioner "file" {
    source      = "shared"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "server_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/server_scripts/setup.sh"]
    expect_disconnect = true
  }

  provisioner "shell" {
    pause_before = "10s"
    inline = ["sudo bash -xe /usr/local/ami_setup/server_scripts/setup_2.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }

  post-processor "manifest" {
    output     = "output/server_manifest.json"
    strip_path = true
  }
}