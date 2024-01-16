packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

data "amazon-ami" "latest-ubuntu" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd/ubuntu-lunar-*-arm64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "tailscale" {
  region               = "us-west-2"
  source_ami           = data.amazon-ami.latest-ubuntu.id
  subnet_id            = "subnet-05c2105bfad11abf9"
  instance_type        = "t4g.small"
  ssh_username         = "ubuntu"
  security_group_id    = "sg-081613d174e1f8e8b" # the public ssh access group for now
  imds_support         = "v2.0"
  ami_name             = "tailscale {{timestamp}}"
  iam_instance_profile = "tailscale"
}

build {
  sources = [
    "source.amazon-ebs.tailscale"
  ]

  provisioner "file" {
    source      = "tailscale_scripts"
    destination = "/tmp"
  }

  provisioner "shell" {
    inline = ["sudo bash -xe /tmp/tailscale_scripts/setup.sh"]
  }

  provisioner "shell" {
    inline = ["sudo rm -rf /tmp/*"]
  }
}
