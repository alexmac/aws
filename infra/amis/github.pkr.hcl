packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "latest-ubuntu" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*-arm64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "github" {
  region     = "us-west-2"
  profile    = "packer"
  source_ami = data.amazon-ami.latest-ubuntu.id
  subnet_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
    most_free = true
    random    = false
  }
  instance_type               = "t4g.small"
  ssh_username                = "ubuntu"
  ssh_interface               = "private_ip"
  temporary_key_pair_name     = "github {{timestamp}}"
  temporary_key_pair_type     = "ed25519"
  associate_public_ip_address = false
  security_group_filter {
    filters = {
      "tag:used_by_packer_instance" : "true"
    }
  }
  imds_support         = "v2.0"
  encrypt_boot         = true
  ami_name             = "github {{timestamp}}"
  iam_instance_profile = "github-vpc-0da7caa17e2e57342"
  deprecate_at         = timeadd(timestamp(), "240h")
  ami_description      = "created from ${data.amazon-ami.latest-ubuntu.id}"
  run_tags = {
    Name = "packer building: github {{timestamp}}"
  }
  snapshot_tags = {
    Name = "github {{timestamp}}"
  }
}

build {
  sources = [
    "source.amazon-ebs.github"
  ]

  provisioner "file" {
    source      = "shared"
    destination = "/tmp"
  }

  provisioner "file" {
    source      = "github_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/github_scripts/setup.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }

  post-processor "manifest" {
    output     = "output/github_manifest.json"
    strip_path = true
  }
}
